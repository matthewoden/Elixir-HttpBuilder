ExUnit.start()
{:ok, _ } = :application.ensure_all_started(:httparrot)
{:ok, _} = :application.ensure_all_started(:proxy)
Task.start(fn -> Proxy.start([]) end)