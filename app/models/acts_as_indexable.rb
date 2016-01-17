module ActsAsIndexable
  module ActsAsMethods

    def acts_as_indexable
      extend IndexableClassMethods
    end

    module IndexableClassMethods
      def get_by_letter(letter)
        self.where("lower(name) LIKE :prefix", prefix: "#{letter}%")
      end
    end

  end
end
