package info.xert.easy_relay;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketException;
import java.nio.ByteBuffer;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public class RelayServer extends Thread {
    class TransferSockets {
        final SocketChannel local;
        final SocketChannel remote;

        TransferSockets(SocketChannel local, SocketChannel remote) {
            this.local = local;
            this.remote = remote;
        }
    }

    Map<UUID, TransferSockets> connections = new HashMap<>();
    final ByteBuffer buffer;

    String targetAddress;
    int targetPort;
    int listenPort;
    ServerSocketChannel serverSocket;

    Selector selector;

    RelayServer(String targetAddress, int targetPort, int listenPort) {
        this.targetAddress = targetAddress;
        this.targetPort = targetPort;
        this.listenPort = listenPort;

        buffer = ByteBuffer.allocate(2048);
    }

    private void onRegister(Selector selector, ServerSocketChannel serverSocket) throws IOException {
        UUID mapKey = UUID.randomUUID();

        SocketChannel client = serverSocket.accept();
        if (client == null) {
            return;
        }
        client.configureBlocking(false);

        SelectionKey clientKey = client.register(selector, SelectionKey.OP_READ);
        clientKey.attach(mapKey);

        SocketChannel targetSocket = SocketChannel.open(new InetSocketAddress(targetAddress, targetPort));
        targetSocket.configureBlocking(false);

        SelectionKey targetKey = targetSocket.register(selector, SelectionKey.OP_READ);
        targetKey.attach(mapKey);

        connections.put(mapKey, new TransferSockets(client, targetSocket));
    }

    private void answer(SelectionKey readKey) {
        UUID mapKey = (UUID) readKey.attachment();
        SocketChannel input = (SocketChannel) readKey.channel();
        TransferSockets transferSockets = connections.get(mapKey);
        if(transferSockets == null) {
            return;
        }

        SocketChannel peer = transferSockets.local.socket() == input.socket() ? transferSockets.remote : transferSockets.local;

        try {
            final int bytes_read = input.read(buffer);
            if (bytes_read == -1) {
                closeConnection(mapKey);
                return;
            }

            if (!peer.isConnected()) {
                closeConnection(mapKey);
                return;
            }

            buffer.flip();
            peer.write(buffer);
            buffer.clear();
        } catch (IOException e) {
            closeConnection(mapKey);
        }
    }

    @Override
    public void run() {

        try {
            selector = Selector.open();

            serverSocket = ServerSocketChannel.open();
            serverSocket.bind(new InetSocketAddress(listenPort));
            serverSocket.configureBlocking(false);
            serverSocket.register(selector, SelectionKey.OP_ACCEPT);

            while (true) {
                selector.select();
                Set<SelectionKey> selectedKeys = selector.selectedKeys();
                Iterator<SelectionKey> iter = selectedKeys.iterator();

                while (iter.hasNext()) {
                    final SelectionKey key = iter.next();
                    iter.remove();

                    if (key.isAcceptable()) {
                        onRegister(selector, serverSocket);
                    } else if (key.isReadable()) {
                        answer(key);
                    }
                }
            }

        } catch (SocketException ignored) {

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    private void closeConnection(UUID uuid) {
        if (connections.containsKey(uuid)) {
            TransferSockets transferSockets = connections.get(uuid);
            assert transferSockets != null;

            try {
                if (transferSockets.local != null) {
                    transferSockets.local.close();
                }
            } catch (IOException ignored) {

            }

            try {
                if (transferSockets.remote != null) {
                    transferSockets.remote.close();
                }
            } catch (IOException ignored) {

            }
        }
        connections.remove(uuid);
    }


    void stopServer() {
        for (Map.Entry<UUID, TransferSockets> entry : connections.entrySet()) {
            try {
                entry.getValue().local.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        try {
            serverSocket.close();
        } catch (IOException ignored) {
        }

        selector.wakeup();
    }
}
