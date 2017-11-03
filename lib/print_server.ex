require Logger
defmodule PRINT_SERVER do
    def listen do
        receive do
            {:response, response} -> IO.puts response
        end
        listen()
    end

    def acceptor(socket) do
        {:ok, client} = :gen_tcp.accept(socket)
        spawn fn -> serveWrite(client) end
        acceptor(socket)
    end

    def serveWrite(client) do
        {:ok, print_message} = :gen_tcp.recv(client, 0)
        IO.puts print_message
        serveWrite(client)
    end
    
end