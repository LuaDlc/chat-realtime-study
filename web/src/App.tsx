import { useState } from 'react';
import { useSocket } from './hooks/useSocket';

function App() {
  const { messages, sendMessage, deleteMessage } = useSocket();
  
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
              <div className="flex items-end gap-2 group">
                
                {isMe && (
                  <button
                    onClick={() => deleteMessage(msg.id)}
                    className="text-gray-500 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-opacity p-1"
                    title="Excluir mensagem"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                )}
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