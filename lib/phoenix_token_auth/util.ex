defmodule PhoenixTokenAuth.Util do
  import Plug.Conn
  import Phoenix.Controller
  require PhoenixTokenAuth.Gettext

  def repo do
    Application.get_env(:phoenix_token_auth, :repo)
  end

  def crypto_provider do
    Application.get_env(:phoenix_token_auth, :crypto_provider, Comeonin.Bcrypt)
  end

  def send_error(conn, error, status \\ 422) do
       errors = Enum.map(error, fn {field, detail} ->
        %{
          source: %{ pointer: "/data/attributes/#{field}" },
           title: "Invalid Attribute",
           detail: render_detail(detail)
        }
      end)

    json conn |> put_status(status),  %{errors: errors}
  end

 def render_detail({msg, opts}) do
       gt = Application.get_env(:phoenix_token_auth, :gettext)
       if count = opts[:count] do
           Gettext.dngettext(gt, "errors", msg, msg, count, opts)
          else
           Gettext.dgettext(gt, "errors", msg, opts)
          end
   end

   def render_detail(message) do
      gt = Application.get_env(:phoenix_token_auth, :gettext)
       Gettext.dgettext(gt, "errors", message)
   end

  def presence_validator(field, nil), do: [{field, "can't be blank"}]
  def presence_validator(field, ""), do: [{field, "can't be blank"}]
  def presence_validator(_field, _), do: []

  def token_from_conn(conn) do
    Plug.Conn.get_req_header(conn, "authorization")
    |> token_from_header
  end
  defp token_from_header(["Bearer " <> token]), do: {:ok, token}
  defp token_from_header(_), do: {:error, :not_present}

end
