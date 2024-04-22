# frozen_string_literal: true

def load_fixture(folder, filename)
  File.read(Rails.root.join('spec', 'support', 'fixtures', folder, "#{filename}.json"))
end
