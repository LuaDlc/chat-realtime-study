import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

interface CreateMessageDTO {
  content: string;
  userId: string;
}

export const messageService = {
  async createMessage(data: CreateMessageDTO) {
    const message = await prisma.message.create({
      data: {
        content: data.content,
        userId: data.userId,
      },
    });
    return message;
  },

  async deleteMessage(id: number) {
    return prisma.message.delete({
      where: { id },
    });
  },

  async getRecentMessages() {
    const messages = await prisma.message.findMany({
      take: 50,
      orderBy: {
        createdAt: "asc",
      },
    });
    return messages;
  },
};
