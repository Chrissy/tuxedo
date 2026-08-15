# frozen_string_literal: true

require_relative '../static_exporter'

namespace :static do
  desc 'Export the public Rails site to static_dist for Cloudflare Pages'
  task export: :environment do
    output_dir = ENV.fetch('OUTPUT_DIR', StaticExporter::DEFAULT_OUTPUT_DIR)
    host = ENV.fetch('STATIC_EXPORT_HOST', StaticExporter::DEFAULT_HOST)

    result = StaticExporter.new(output_dir: output_dir, host: host).export!

    puts "Static export complete:"
    puts "  output: #{result[:output_dir]}"
    puts "  files:  #{result[:file_count]}"
    puts "  html:   #{result[:html_count]}"
    puts "  json:   #{result[:json_count]}"
  end

  desc 'Validate an existing static export directory'
  task validate: :environment do
    output_dir = ENV.fetch('OUTPUT_DIR', StaticExporter::DEFAULT_OUTPUT_DIR)
    host = ENV.fetch('STATIC_EXPORT_HOST', StaticExporter::DEFAULT_HOST)

    result = StaticExporter.new(output_dir: output_dir, host: host).validate!

    puts "Static export valid:"
    puts "  output: #{result[:output_dir]}"
    puts "  files:  #{result[:file_count]}"
    puts "  html:   #{result[:html_count]}"
    puts "  json:   #{result[:json_count]}"
  end

  desc 'Print the static export URL manifest without rendering files'
  task routes: :environment do
    output_dir = ENV.fetch('OUTPUT_DIR', StaticExporter::DEFAULT_OUTPUT_DIR)
    host = ENV.fetch('STATIC_EXPORT_HOST', StaticExporter::DEFAULT_HOST)

    StaticExporter.new(output_dir: output_dir, host: host).public_paths.each do |path|
      puts path
    end
  end
end
