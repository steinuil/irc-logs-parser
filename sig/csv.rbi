type csv_value = _ToS | nil

class CSV
  def self.open: (String, String) { (CSV) -> any } -> void
  def <<: (Array<csv_value>) -> void
end
