if Code.ensure_loaded?(HTTPotion) do
    defmodule HttpBuilder.Adapters.HTTPotion do
        alias HttpBuilder.HttpRequest
        
        @moduledoc """
        An adapter for using HTTPotion. Expects a JSON parser to be
        included in the HTTPBuilder configuration for encoding requests. 
      
        Returns `HTTPotion` structs as responses. 
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
                method: request.method,
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
            uri = request.host <> request.path
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
            potion_options = 
                [
                    body: format_body(request),
                    headers: format_headers(request.headers),
                    timeout: request.req_timeout,
                ] 
            
            request.options
            |> Enum.map(fn 
                    { :ibrowse, options } -> { :ibrowse, options |> Keyword.put(:connect_timeout, request.rec_timeout) }
                    item -> item
                end)
            |> Enum.concat(potion_options)
        end

        defp do_send(request) do
            HTTPotion.request(
                request.method,
                request.uri,
                request.options
            )
        end
    end
end