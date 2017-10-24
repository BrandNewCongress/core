defmodule Core.TurboVdomPlug do
  def init(default), do: default

  def call(conn = %Plug.Conn{params: %{"empty" => "true"}}, _default) do
    Phoenix.Controller.put_layout(conn, {Core.LayoutView, "empty.html"})
  end

  def call(conn, _default) do
    conn
  end
end
