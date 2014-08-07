require 'interpipe/interactor'

module Interpipe
  class Organizer
    include Interactor

    def self.[](*interactors)
      anon_class = Class.new(self)
      anon_class.interactors = interactors
      anon_class
    end

    def self.interactors
      @interactors ||= []
    end

    def self.interactors=(interactors)
      @interactors = interactors
    end

    def interactors
      self.class.interactors
    end
  end
end
