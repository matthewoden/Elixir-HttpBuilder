if Code.ensure_loaded?(HTTPoison) do
    defmodule HttpBuilder.Adapters.HTTPoison do
        alias HttpBuilder.HttpRequest
        
        @moduledoc """
        An adapter for using HTTPoison. Expects a JSON parser to be
        included in the HTTPBuilder configuration for encoding requests. 

        Returns `HTTPoison` structs as responses. 
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
                options: create_options(request),
                method: request.method,
                uri: request.host <> request.path,
                body: format_body(request),
                headers: request.headers,
            }
        end
        
        defp format_body(%{ body: nil }), do: ""
        defp format_body(%{ body: {:other, body} }), do: body
        defp format_body(%{ body: {:string, body} }), do: body
        defp format_body(%{ body: {:json, body} } = request), do: request.json_parser.encode!(body)
        defp format_body(%{ body: {atom, body} }), do: {atom, body}
        
        defp create_options(request) do
            timeout_options = [ 
                timeout: request.req_timeout, 
                recv_timeout: request.rec_timeout,
            ]

            params_options = if length(request.query_params) != 0, 
                do: [params: request.query_params], else: []

            params_options ++ timeout_options ++ request.options
        end

        defp do_send(request) do
            HTTPoison.request(
                request.method,
                request.uri,
                request.body,
                request.headers,
                request.options
            )
        end
    end
end