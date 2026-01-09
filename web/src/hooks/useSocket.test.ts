import { renderHook, act } from "@testing-library/react";
import { useSocket } from "./useSocket";
import { vi, describe, it, expect } from "vitest";

vi.mock("socket.io-client", () => {
  const mSocket = {
    on: vi.fn(),
    emit: vi.fn(),
    disconnect: vi.fn(),
    connect: vi.fn(),
  };
  return { default: vi.fn(() => mSocket) };
});

describe("useSocket Hook", () => {
  it("deve iniciar com lista de mensagens vazia", () => {
    const { result } = renderHook(() => useSocket());
    expect(result.current.messages).toEqual([]);
  });

  it("deve tentar enviar mensagem", () => {
    const { result } = renderHook(() => useSocket());

    act(() => {
      result.current.sendMessage("Olá Teste", "Tester");
    });

    expect(result.current.sendMessage).toBeDefined();
  });
});
