import express from "express";
import http from "http";
import { Server } from "socket.io";
import cors from "cors";
import { messageService } from "./services/messageService"; // <--- Importamos o serviço

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

io.on("connection", async (socket) => {
  console.log(` Cliente conectado: ${socket.id}`);

  try {
    const history = await messageService.getRecentMessages();
    socket.emit("previous_messages", history);
  } catch (err) {
    console.error("Erro ao buscar histórico:", err);
  }

  socket.on("send_message", async (data: any) => {
    console.log(` Recebido:`, data);

    if (!data.texto || !data.usuario) {
      return;
    }

    try {
      const savedMessage = await messageService.createMessage({
        content: data.texto,
        userId: data.usuario,
      });

      io.emit("receive_message", savedMessage);
    } catch (err) {
      console.error("Erro ao salvar mensagem:", err);
    }
  });
  socket.on("delete_message", async (messageId: number) => {
    try {
      await messageService.deleteMessage(messageId);

      io.emit("message_deleted", messageId);
      console.log(` Mensagem ${messageId} apagada.`);
    } catch (err) {
      console.error("Erro ao apagar:", err);
    }
  });

  socket.on("disconnect", () => {
    console.log(` Cliente desconectado: ${socket.id}`);
  });
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(` Servidor rodando em http://localhost:${PORT}`);
});
