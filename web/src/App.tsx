import { useState } from 'react';
import { useSocket } from './hooks/useSocket';

function App() {
  const { messages, sendMessage } = useSocket();
  
  const [inputText, setInputText] = useState('');
  const [myUser] = useState('LuanaWeb'); 

  const handleSend = () => {
    if (inputText.trim()) {
      sendMessage(inputText, myUser);
      setInputText(''); 
    }
  };

  return (
    <div className="flex flex-col h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="p-4 bg-gray-800 shadow-md">
        <h1 className="text-xl font-bold text-blue-400">💬 Chat Real-time</h1>
        <p className="text-xs text-gray-400">Conectado como: {myUser}</p>
      </div>

      {/* Lista de Mensagens (Área de Scroll) */}
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.map((msg) => {
          const isMe = msg.userId === myUser;
          return (
            <div
              // eslint-disable-next-line react-hooks/purity
              key={msg.id || Math.random()} // Fallback para key se id vier nulo
              className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-xs px-4 py-2 rounded-lg ${
                  isMe
                    ? 'bg-blue-600 text-white rounded-br-none'
                    : 'bg-gray-700 text-gray-200 rounded-bl-none'
                }`}
              >
                <p className="font-bold text-xs opacity-70 mb-1">{msg.userId}</p>
                <p>{msg.content}</p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Input Area */}
      <div className="p-4 bg-gray-800 flex gap-2">
        <input
          type="text"
          className="flex-1 bg-gray-700 text-white rounded-lg px-4 py-2 outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="Digite sua mensagem..."
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSend()}
        />
        <button
          onClick={handleSend}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-bold transition-colors"
        >
          Enviar
        </button>
      </div>
    </div>
  );
}

export default App;