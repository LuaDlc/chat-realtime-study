// web/src/hooks/useSocket.ts
import { useEffect, useState } from "react";
import io, { Socket } from "socket.io-client";
import type { Message } from "../types";

const SOCKET_URL = "http://localhost:3000";

export const useSocket = () => {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    // 1. Conexão (Equivalente ao initState)
    const newSocket = io(SOCKET_URL);
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setSocket(newSocket);

    // 2. Listeners (Ouvidos)
    newSocket.on("connect", () => {
      console.log("Conectado ao Backend:", newSocket.id);
    });

    // Carga inicial (Histórico)
    newSocket.on("previous_messages", (history: Message[]) => {
      setMessages(history);
    });

    // Nova mensagem chegando (Tempo Real)
    newSocket.on("receive_message", (newMessage: Message) => {
      // Estado Imutável: Cria um array novo com tudo que tinha antes + a nova
      setMessages((prev) => [...prev, newMessage]);
    });

    // 3. Cleanup (Equivalente ao dispose)
    // O React roda isso quando o componente morre ou recarrega.
    return () => {
      console.log("Desconectando...");
      newSocket.disconnect();
    };
  }, []); // Array vazio [] significa: "Execute apenas uma vez na montagem"

  // Função para enviar (Exposta para a View usar)
  const sendMessage = (text: string, user: string) => {
    if (socket) {
      socket.emit("send_message", {
        texto: text,
        usuario: user,
      });
    }
  };

  return { messages, sendMessage, isConnected: !!socket };
};
