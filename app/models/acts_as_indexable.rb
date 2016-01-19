module ActsAsIndexable
  module ActsAsMethods

    def acts_as_indexable
      extend IndexableClassMethods
    end

    module IndexableClassMethods
      def get_by_letter(letter)
        self.where("lower(name) LIKE :prefix", prefix: "#{letter}%")
      end

      def all_grouped_by_letter
        self.all_for_display.group_by { |element| element.name[0].upcase }
      end
    end

  end
end
