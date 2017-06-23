defmodule Format do
  def as_zip(zip), do: String.pad_leading("#{zip}", 5 - String.length(zip), "0")

  def as_float({num, ""}), do: num
  def as_float(:error), do: :error
  def as_float(string), do: as_float(Float.parse(string))

  def as_int({num, ""}), do: num
  def as_int(:error), do: :error
  def as_int(string), do: as_int(Integer.parse(string))
end
