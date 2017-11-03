defmodule Server do

    def serverPort, do: 19911
    def clientPort, do: 19044

    def loop() do
        loop()
    end
    
    def main(args) do
        {_, [str], _} = OptionParser.parse(args)
        #str=args
        if str =~ "." do
          
            ipAddr = String.to_charlist(str)
            {:ok, socket1 } = :gen_tcp.connect(ipAddr, serverPort(), [{:active, false}])
            {:ok, response} = :gen_tcp.recv(socket1, 0)
            k = String.to_integer(to_string response)
            {:ok, socket2} = :gen_tcp.connect(ipAddr, clientPort(), [{:active, false}])

            spawn(WORKER, :encryptInputClient, [k, 0, str, socket2])
            loop()
        else
            k = elem(Integer.parse(str), 0)
            ser_PID = spawn(PRINT_SERVER, :listen, [])
            cores=8
            spawnMultiple(k, ser_PID, cores)
            {:ok, socket2} = :gen_tcp.listen(clientPort(),[{:active, false}])
            spawn(PRINT_SERVER, :acceptor, [socket2])
            {:ok, socket1} = :gen_tcp.listen(serverPort(),[{:active, false}])
            acceptor(k, socket1)
        end
    end

    def acceptor(k, socket) do       
        {:ok, client} = :gen_tcp.accept(socket)
        spawn fn -> serveWrite(client, Integer.to_string(k)) end
        acceptor(k, socket)
    end

    def serveWrite(client, k) do
        :gen_tcp.send(client, k)
    end

    def spawnMultiple(k, ser_PID, n) when n <= 1 do
        spawn(WORKER, :encryptInput, [ k, 0, ser_PID])
    end
  
    def spawnMultiple(k, ser_PID, n) do
        spawn(WORKER, :encryptInput, [ k, 0, ser_PID])
        spawnMultiple(k, ser_PID, n-1)
    end

end