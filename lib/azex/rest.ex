defmodule Azex.Rest do
	alias HTTPipe.Conn

	@account Application.get_env(:azex, :account)
	@key Application.get_env(:azex, :key) |> Base.decode64!

	def exec(resource, method \\ "GET", body \\ nil, headers \\ []) do
		resource = URI.encode(resource, &URI.char_unreserved?/1)
		date = :httpd_util.rfc1123_date()
		signature = "#{date}\n/#{@account}/#{resource}" |> IO.inspect
		signature = :crypto.hmac(:sha256, @key, signature) |> Base.encode64
		url = "http://#{@account}.table.core.windows.net/#{resource}"
		conn =
			Conn.new
			|> Conn.put_req_header("Authorization", "SharedKeyLite #{@account}:#{signature}")
			|> Conn.put_req_header("x-ms-date", date)
			|> Conn.put_req_header("x-ms-version", "2016-05-31")
			|> Conn.put_req_header("Content-Type", "application/json")
			|> Conn.put_req_header("Accept", "application/json")
			|> Conn.put_req_header("DataServiceVersion", "3.0;NetFx")
			|> Conn.put_req_method(method)
			|> Conn.put_req_url(url)
			|> Conn.put_req_body(Poison.encode!(body))
		conn =
			headers
			|> Enum.reduce(conn, fn {key, value}, conn ->
				Conn.put_req_header(conn, key, value)
			end)
		conn
		|> Conn.execute!
		|> Map.get(:response)
		|> Map.get(:body)
		|> Poison.decode!
	end
end