defmodule TwitterWeb.PageController do
  use TwitterWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
