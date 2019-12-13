defmodule Twitter_backend.Token do
	use Twitter_backend, :controller

	def unauthenticated(conn, _params) do
		conn
		|> redirect(to: session_path(conn, :new))
	end

	def unauthorized(conn, _params) do
	    conn
	    |> redirect(to: session_path(conn, :new))
  	end
end
