if Code.ensure_loaded?(:hackney) do
    defmodule HttpBuilder.Adapters.Hackney do
        alias HttpBuilder.HttpRequest

        @moduledoc """
        An adapter for using `:hackney`. Expects a JSON parser to be
        included in the HTTPBuilder configuration for encoding requests. 
        
            config :http_builder, HttpBuilder.Adapters.Hackney
                json_parser: HttpBuilder.Adapters.JSONParser.Poison
        
        If you have `Poison` as a dependancy, then this adapter will be 
        selected by default.

        """


        @behaviour HttpBuilder.Adapter

        @default_parser if Code.ensure_loaded?(Poison), do: HttpBuilder.Adapters.JSONParser.Poison, else: nil
        
        @config Application.get_env(:http_builder, __MODULE__, [json_parser: @default_parser])

        @parser Keyword.get(@config, :json_parser) || raise "No JSON parser configured. Please add a parser to #{__MODULE__}'s configuration."

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
                uri: format_uri(request),
                body: format_body(request.body),
                headers: request.headers,
            }
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

        defp format_body(nil), do: ""
        defp format_body({:other, body}), do: body
        defp format_body({:string, body}), do: body
        defp format_body({:json, body}), do: @parser.encode!(body)
        defp format_body({atom, body}), do: {atom, body}
       
        defp create_options(request) do
            timeout_options = [ 
                connect_timeout: request.req_timeout, 
                recv_timeout: request.rec_timeout,
            ]

            timeout_options ++ request.options
        end
        
        defp do_send(%{body: {:stream, enumerable} } = request) do
            with {:ok, ref} <- :hackney.request(request.method, request.uri, 
                                    request.headers, :stream, request.options)
            do
                failures = 
                    enumerable
                    |> Stream.transform(:ok, fn
                            _, :error -> 
                                {:halt, :error}

                            bin, :ok  -> 
                                {[], :hackney.send_body(ref, bin)}

                            _, error  -> 
                                {[error], :error}
                        end) 
                    |> Enum.into([])
        
                case failures do
                    [] ->
                        :hackney.start_response(ref)

                    [failure] ->
                        failure
                end
            end
        end

        defp do_send(request) do
            :hackney.request(request.method, request.uri, request.headers,
                request.body, request.options)
        end
    end
end    