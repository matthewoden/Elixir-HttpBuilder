if Code.ensure_loaded?(HTTPoison) do
    defmodule HttpBuilder.Adapters.HTTPosion do
        alias HttpBuilder.HttpRequest
        
        @moduledoc """
        An adapter for using HTTPoison. Expects a JSON parser to be
        included in the HTTPBuilder configuration for encoding requests. 
        
            config :http_builder, HttpBuilder.Adapters.HTTPosion
                json_parser: HttpBuilder.Adapters.JSONParser.Poison
        
        If you have `Poison` as a dependancy, then this adapter will be 
        selected by default.

        Returns an `HTTPoison` structs as responses. or `HTTPoison.Error`
        """

        
        @behaviour HttpBuilder.Adapter

        @default_parser if Code.ensure_loaded?(Poison), do: HttpBuilder.Adapters.JSONParser.Poison, else: nil
        
        @config Application.get_env(:http_builder, __MODULE__, [json_parser: @default_parser])

        @parser Keyword.get(@config, :json_parser) || raise "No JSON parser configured. Please add a parser to #{__MODULE__}'s configuration."

        @impl true
        @spec send(HttpRequest.t) :: HttpBuilder.Adapter.result
        @doc """"
        Sends a `HttpRequest`
        """
        def send(request), do: request |> format_request() |> do_send()
        
        defp format_request(request) do   
            %{
                options: create_options(request),
                method: request.method,
                uri: request.host <> request.path,
                body: format_body(request.body),
                headers: request.headers,
            }
        end
        
        defp format_body(nil), do: ""
        defp format_body({:other, body}), do: body
        defp format_body({:string, body}), do: body
        defp format_body({:json, body}), do: @parser.encode!(body)
        defp format_body({atom, body}), do: {atom, body}
        
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