if Code.ensure_loaded?(:ibrowse) do
    defmodule HttpBuilder.Adapters.IBrowse do
        alias HttpBuilder.HttpRequest
        
        @moduledoc """
        An adapter for using IBrowse. Expects a JSON parser to be
        included in the HTTPBuilder configuration for encoding requests. 
        """

        @behaviour HttpBuilder.Adapter

        @impl true
        @spec send(HttpRequest.t) :: HttpBuilder.Adapter.result
        @doc """
        Sends a `HttpRequest`
        """
        def send(request), do: request |> format_request() |> do_send()
        
        defp format_request(request) do 

            %{
                options: format_options(request),
                headers: format_headers(request.headers),                
                method: request.method,
                body: format_body(request),
                uri: format_uri(request)
            }
        end
        
        defp format_body(%{ body: nil}), do: ""
        defp format_body(%{ body: {:other, body}}), do: body
        defp format_body(%{ body: {:string, body}}), do: body
        defp format_body(%{ body: {:form, body}}), do: body |> URI.encode_query
        defp format_body(%{ body: {:file, path}}), do: File.read!(path)
        defp format_body(%{ body: {:json, body}} = request), do: request.json_parser.encode!(body)
        
        defp format_headers([]), do: []
        defp format_headers(headers) do
            Keyword.new(headers, fn {key, val} -> {String.to_atom(key), val} end)
        end

        defp format_uri(request) do
            uri = request.host <> request.path |> String.to_charlist
            cond do
                request.query_params == [] ->
                    uri

                URI.parse(uri).query -> 
                    uri <> "&" <> URI.encode_query(request.query_params)

                true ->
                    uri <> "?" <> URI.encode_query(request.query_params)
            end 
        end

        defp format_options(request) do
            [
                inactivity_timeout: request.req_timeout,
                connect_timeout: request.rec_timeout
            ] |> Enum.concat(request.options)
        end

        defp do_send(request) do
            :ibrowse.send_req(
                request.uri,
                request.headers,
                request.method,
                request.body,
                request.options
            )
        end
    end
end