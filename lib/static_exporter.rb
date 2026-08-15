# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'nokogiri'
require 'rack/mock'
require 'set'
require 'time'
require 'uri'

class StaticExporter
  DEFAULT_OUTPUT_DIR = Rails.root.join('static_dist').to_s
  DEFAULT_HOST = 'tuxedono2.com'
  CLOUDFLARE_PAGES_FREE_FILE_LIMIT = 20_000
  HOME_PAGINATION_INTERVAL = 47
  COMPONENT_RECENTS_INTERVAL = 6

  STATIC_REDIRECTS = [
    ['/list/chartreuse-cocktail-recipes', '/ingredients/chartreuse-cocktail-recipes', 301],
    ['/list/holiday-cocktails-cocktail-recipes', '/ingredients/chartreuse-cocktail-recipes', 301],
    ['/list/tequila-cocktail-recipes-162045e6-2cfb-4e15-b67b-55abc1899bd7', '/ingredients/chartreuse-cocktail-recipes', 301],
    ['/list/whiskey-cocktails-cocktail-recipes', '/ingredients/chartreuse-cocktail-recipes', 301],
    ['/list/fall-cocktails-cocktail-recipes', '/tags/fall', 301],
    ['/list/rum-cocktail-recipes', '/ingredients/rum-cocktail-recipes', 301],
    ['/list/rum-cocktails-cocktail-recipes', '/ingredients/rum-cocktail-recipes', 301],
    ['/admin', '/', 302],
    ['/users/*', '/', 302],
    ['/edit/*', '/', 302],
    ['/ingredients/edit/*', '/', 302],
    ['/new', '/', 302],
    ['/ingredients/new', '/', 302],
    ['/delete/*', '/', 302],
    ['/ingredients/delete/*', '/', 302],
    ['/image-upload-token', '/', 302]
  ].freeze

  LINK_ATTRIBUTES = %w[
    href
    src
    data-lazy-load-on-scroll
    data-lazy-load-on-click
  ].freeze

  attr_reader :output_dir, :host

  def initialize(output_dir: DEFAULT_OUTPUT_DIR, host: DEFAULT_HOST)
    @output_dir = File.expand_path(output_dir)
    @host = host
    @request = Rack::MockRequest.new(Rails.application)
    @rendered_paths = []
    @redirects = STATIC_REDIRECTS.dup
  end

  def export!
    assert_safe_output_dir!
    assert_assets_built!

    FileUtils.rm_rf(output_dir)
    FileUtils.mkdir_p(output_dir)

    copy_public_assets
    render_public_routes
    write_redirects
    write_headers
    write_manifest

    validate!
  end

  def validate!
    assert_safe_output_dir!
    raise "Static export directory does not exist: #{output_dir}" unless Dir.exist?(output_dir)

    file_count = Dir.glob(File.join(output_dir, '**', '*'), File::FNM_DOTMATCH).count { |path| File.file?(path) }
    raise "Cloudflare Pages Free file limit exceeded: #{file_count} files" if file_count > CLOUDFLARE_PAGES_FREE_FILE_LIMIT

    missing = missing_internal_links
    raise "Static export has missing internal targets:\n#{missing.join("\n")}" if missing.any?

    {
      file_count: file_count,
      html_count: Dir.glob(File.join(output_dir, '**', '*.html')).count,
      json_count: Dir.glob(File.join(output_dir, '**', '*.json')).count,
      output_dir: output_dir
    }
  end

  def public_paths
    paths = []
    paths.concat(base_paths)
    paths.concat(letter_index_paths)
    paths.concat(recipe_paths)
    paths.concat(component_paths)
    paths.concat(tag_paths)
    paths.concat(home_fragment_paths)
    paths.concat(component_fragment_paths)
    paths.uniq.sort
  end

  private

  def base_paths
    [
      '/',
      '/about',
      '/index',
      '/recipes',
      '/ingredients',
      '/autocomplete.json'
    ]
  end

  def letter_index_paths
    index_letters = Recipe.all.pluck(:name).concat(Component.all.pluck(:name)).filter_map { |name| name.to_s[0]&.downcase }.uniq
    recipe_letters = Recipe.all.pluck(:name).filter_map { |name| name.to_s[0]&.downcase }.uniq
    component_letters = Component.all.pluck(:name).filter_map { |name| name.to_s[0]&.downcase }.uniq

    paths = ('a'..'z').flat_map do |letter|
      [
        "/index/#{letter}",
        "/recipes/#{letter}",
        "/ingredients-index/#{letter}"
      ]
    end

    paths.concat(index_letters.map { |letter| "/index/#{letter}" })
    paths.concat(recipe_letters.map { |letter| "/recipes/#{letter}" })
    paths.concat(component_letters.map { |letter| "/ingredients-index/#{letter}" })
    paths
  end

  def recipe_paths
    Recipe.all.map(&:url)
  end

  def component_paths
    Component.all.map(&:url).concat(Subcomponent.all.map(&:url))
  end

  def tag_paths
    Recipe.all.flat_map(&:tag_list).uniq.map do |tag|
      "/tags/#{tag.gsub(' ', '-')}"
    end
  end

  def home_fragment_paths
    recipe_count = Recipe.all_for_home.count
    page = 1
    paths = []

    while (HOME_PAGINATION_INTERVAL * page + 1) < recipe_count
      paths << "/index/more/#{page}"
      page += 1
    end

    paths
  end

  def component_fragment_paths
    Component.all.find_each.flat_map do |component|
      paths = []
      page = 1

      while export_component_recent_fragment?(component, page)
        paths << "/ingredients/#{component.id}/recents/#{page}"
        page += 1
      end

      paths
    end
  end

  def component_recent_start(page)
    page == 1 ? 3 : COMPONENT_RECENTS_INTERVAL * page + 1
  end

  def export_component_recent_fragment?(component, page)
    item_count = component.all_elements.count
    start = component_recent_start(page)

    page == 1 ? start <= item_count : start < item_count
  end

  def render_public_routes
    public_paths.each do |path|
      response = get(path)

      if redirect?(response)
        @redirects << [path, normalize_redirect_location(response.location), response.status]
        next
      end

      unless response.status == 200
        raise "Failed to export #{path}: HTTP #{response.status}\n#{response.body}"
      end

      body = html_path?(path) ? post_process_html(response.body) : response.body
      write_path(path, body)
      @rendered_paths << path
    end
  end

  def get(path)
    @request.get(
      path,
      'HTTP_HOST' => host,
      'HTTPS' => 'on',
      'rack.url_scheme' => 'https',
      'HTTP_USER_AGENT' => 'Tuxedo static export'
    )
  end

  def redirect?(response)
    response.status >= 300 && response.status < 400 && response.location.present?
  end

  def html_path?(path)
    File.extname(path).empty?
  end

  def post_process_html(html)
    html
      .gsub(%r{\s*<a class="global-header__link authenticate" href="/admin" data-admin-link>Admin</a>}, '')
      .gsub(%r{\s*<a class="global-header__link authenticate" data-edit-link href="[^"]+">Edit</a>}, '')
  end

  def write_path(path, body)
    destination = destination_path(path)
    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, body)
  end

  def destination_path(path)
    return File.join(output_dir, 'site-index.html') if path == '/index'

    clean_path = path.sub(%r{\A/}, '')
    clean_path = 'index' if clean_path.empty?
    clean_path += '.html' if File.extname(clean_path).empty?
    File.join(output_dir, clean_path)
  end

  def copy_public_assets
    Dir.glob(Rails.root.join('public', '*'), File::FNM_DOTMATCH).each do |path|
      basename = File.basename(path)
      next if basename == '.' || basename == '..'

      FileUtils.cp_r(path, File.join(output_dir, basename))
    end
  end

  def write_redirects
    lines = @redirects.uniq.map { |from, to, status| "#{from} #{to} #{status}" }
    File.write(File.join(output_dir, '_redirects'), "#{lines.join("\n")}\n")
  end

  def write_headers
    File.write(
      File.join(output_dir, '_headers'),
      <<~HEADERS
        /*
          X-Content-Type-Options: nosniff

        /dist/*
          Cache-Control: public, max-age=31536000, immutable

        /images/*
          Cache-Control: public, max-age=31536000

        /svg/*
          Cache-Control: public, max-age=31536000

        /webfonts/*
          Cache-Control: public, max-age=31536000
      HEADERS
    )
  end

  def write_manifest
    manifest = {
      generated_at: Time.now.utc.iso8601,
      host: host,
      rendered_paths: @rendered_paths,
      redirects: @redirects.uniq.map { |from, to, status| { from: from, to: to, status: status } }
    }

    File.write(File.join(output_dir, 'static-export-manifest.json'), JSON.pretty_generate(manifest))
  end

  def missing_internal_links
    existing_targets = Set.new
    Dir.glob(File.join(output_dir, '**', '*')).each do |path|
      next unless File.file?(path)

      relative = path.delete_prefix("#{output_dir}/")
      existing_targets << "/#{relative}"
      existing_targets << route_for_file(relative)
    end

    redirect_sources = exported_redirect_sources
    missing = []

    Dir.glob(File.join(output_dir, '**', '*.html')).each do |html_path|
      Nokogiri::HTML(File.read(html_path)).css('*').each do |node|
        LINK_ATTRIBUTES.each do |attribute|
          target = node[attribute]
          normalized = normalize_internal_target(target)
          next unless normalized
          next if existing_targets.include?(normalized)
          next if redirected?(normalized, redirect_sources)

          missing << "#{html_path.delete_prefix("#{output_dir}/")}: #{target}"
        end
      end
    end

    missing.uniq.sort
  end

  def redirected?(path, redirect_sources)
    redirect_sources.include?(path) ||
      redirect_sources.any? { |source| source.end_with?('*') && path.start_with?(source.delete_suffix('*')) }
  end

  def exported_redirect_sources
    sources = @redirects.map(&:first)
    redirects_file = File.join(output_dir, '_redirects')

    if File.exist?(redirects_file)
      File.readlines(redirects_file).each do |line|
        next if line.strip.empty? || line.start_with?('#')

        sources << line.split(/\s+/).first
      end
    end

    sources.to_set
  end

  def route_for_file(relative)
    return '/' if relative == 'index.html'
    return "/#{relative.delete_suffix('.html')}" if relative.end_with?('.html')

    "/#{relative}"
  end

  def normalize_internal_target(target)
    return nil if target.blank?
    return nil if target.start_with?('#', 'mailto:', 'tel:', 'http://', 'https://', '//')

    path = target.split('#', 2).first.split('?', 2).first
    return nil if path.blank?

    path.start_with?('/') ? path : "/#{path}"
  end

  def normalize_redirect_location(location)
    uri = URI.parse(location)
    return location unless uri.host == host

    path = uri.path.presence || '/'
    uri.query.present? ? "#{path}?#{uri.query}" : path
  rescue URI::InvalidURIError
    location
  end

  def assert_safe_output_dir!
    root = Rails.root.to_s
    raise "Refusing to export over Rails.root: #{output_dir}" if output_dir == root
    raise "Refusing to export outside the app: #{output_dir}" unless output_dir.start_with?("#{root}/")
  end

  def assert_assets_built!
    required_assets = [
      Rails.root.join('public', 'dist', 'application.js'),
      Rails.root.join('public', 'dist', 'application.css'),
      Rails.root.join('public', 'dist', 'sprite.svg')
    ]

    missing = required_assets.reject { |path| File.exist?(path) }
    return if missing.empty?

    raise "Missing built assets:\n#{missing.join("\n")}\nRun `npm run build` before `bundle exec rake static:export`."
  end
end
