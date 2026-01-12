import { useEffect, useState } from "react";
import io, { Socket } from "socket.io-client";
import type { Message } from "../types";

const SOCKET_URL = "http://localhost:3000";

export const useSocket = () => {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    const newSocket = io(SOCKET_URL);
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setSocket(newSocket);

    newSocket.on("connect", () => {
      console.log("Conectado ao Backend:", newSocket.id);
    });

    newSocket.on("previous_messages", (history: Message[]) => {
      setMessages(history);
    });

    newSocket.on("receive_message", (newMessage: Message) => {
      setMessages((prev) => [...prev, newMessage]);
    });

    newSocket.on("message_deleted", (deletedId: number) => {
      setMessages((prev) => prev.filter((msg) => msg.id !== deletedId));
    });

    return () => {
      console.log("Desconectando...");
      newSocket.disconnect();
    };
  }, []);

  const sendMessage = (text: string, user: string) => {
    if (socket) {
      socket.emit("send_message", {
        texto: text,
        usuario: user,
      });
    }
  };

  const deleteMessage = (messageId: number) => {
    if (socket) {
      socket.emit("delete_message", messageId);
    }
  };

  return { messages, sendMessage, deleteMessage, isConnected: !!socket };
};
