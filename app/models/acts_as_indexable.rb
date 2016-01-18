module ActsAsIndexable
  module ActsAsMethods

    def acts_as_indexable
      extend IndexableClassMethods

      define_method(:indexable_letter) do
        self.name[0].downcase
      end
    end

    module IndexableClassMethods
      def get_by_letter(letter)
        self.where("lower(name) LIKE :prefix", prefix: "#{letter}%")
      end
    end

  end
end
