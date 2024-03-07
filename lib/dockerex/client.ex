defmodule Dockerex.Client do
  require Logger

  defp base_url() do
    host = Application.get_env(:dockerex, :host)
    "#{host}"
  end

  defp options() do
    Application.get_env(:dockerex, :options, [])
  end

  defp default_headers() do
    {:ok, hostname} = :inet.gethostname()
    %{"Content-Type" => "application/json", "Host" => hostname}
  end

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(host, resource, headers \\ default_headers(), opt \\ []) do
    Logger.debug("Sending GET request to the Docker HTTP API: #{resource}")

    (host <> resource)
    |> HTTPoison.get!(Map.merge(headers, default_headers()), Keyword.merge(options(), opt))
    |> decode_body
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(host, resource, data \\ "", headers \\ default_headers(), opt \\ []) do
    Logger.debug("Sending POST request to the Docker HTTP API: #{resource}, #{inspect(data)}")
    data = Poison.encode!(data)

    (host <> resource)
    |> HTTPoison.post!(data, Map.merge(headers, default_headers()), Keyword.merge(options(), opt))
    |> decode_body
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(host, resource, headers \\ default_headers(), opt \\ []) do
    Logger.debug("Sending DELETE request to the Docker HTTP API: #{resource}")

    (host <> resource)
    |> HTTPoison.delete!(Map.merge(headers, default_headers()), Keyword.merge(options(), opt))
  end

  defp decode_body(%HTTPoison.Response{body: ""}) do
    Logger.debug("Empty response")
    nil
  end

  defp decode_body(%HTTPoison.Response{body: body}) do
    Logger.debug("Decoding Docker API response: #{inspect(body)}")

    case Poison.decode(body) do
      {:ok, dict} -> dict
      {:error, _} -> body
    end
  end
end
