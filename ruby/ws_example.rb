require 'json'
require 'em-websocket'

$ws_connection = nil

# Thread-safe method to send messages to WebSocket
def send_to_websocket(message)
  return unless $ws_connection
  EM.next_tick do
    begin
      $ws_connection.send(message.to_json)
      puts "Sent to WebSocket: #{message}"
    rescue => e
      puts "Error sending to WebSocket: #{e.message}"
    end
  end
end

# Demo function: Trigger mouth animation
def demo_mouth_animation
  puts "Demo: Mouth talking..."
  send_to_websocket({action: 'mouth', state: 'talk'})
  sleep 2
  send_to_websocket({action: 'mouth', state: 'still'})
end

# Demo function: Show user subtitle
def demo_user_subtitle(text)
  puts "Demo: User subtitle - #{text}"
  send_to_websocket({action: "subtitle", speaker: "user", data: text})
end

# Demo function: Show agent subtitle
def demo_agent_subtitle(text)
  puts "Demo: Agent subtitle - #{text}"
  send_to_websocket({action: "subtitle", speaker: "agent", data: text})
end

# Demo function: Trigger lightning effect
def demo_lightning
  puts "Demo: Lightning effect!"
  send_to_websocket({action: "event", message: "lightning"})
end

# Demo function: Start recording indicator
def demo_start_recording
  puts "Demo: Start recording indicator"
  send_to_websocket({action: "event", message: "start_recording"})
end

# Demo function: Stop recording indicator
def demo_stop_recording
  puts "Demo: Stop recording indicator"
  send_to_websocket({action: "event", message: "stop_recording"})
end

# Run demo sequence
def run_demo_sequence
  sleep 2
  
  # Demo 1: User asks a question
  demo_user_subtitle("What is Halloween?")
  sleep 3
  
  # Demo 2: Agent responds with talking mouth
  demo_agent_subtitle("Halloween is a spooky celebration on October 31st!")
  demo_mouth_animation
  sleep 3
  
  # Demo 3: Lightning effect
  demo_lightning
  sleep 2
  
  # Demo 4: Recording indicators
  demo_start_recording
  sleep 2
  demo_stop_recording
  sleep 2
  
  # Demo 5: Another interaction
  demo_user_subtitle("Tell me a scary story")
  sleep 2
  demo_agent_subtitle("Once upon a midnight dreary...")
  demo_mouth_animation
  
  puts "\nDemo sequence complete!"
end

def main
  trap("INT") do
    puts "\nExiting..."
    EM.stop
    exit
  end

  EM.run do
    EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |ws|
      ws.onopen do 
        puts "WebSocket client connected!"
        $ws_connection = ws
        ws.send({type: "status", message: "Connected to demo server"}.to_json)
        
        # Start demo sequence after connection
        Thread.new { run_demo_sequence }
      end

      ws.onclose do
        puts "WebSocket connection closed"
        $ws_connection = nil
      end

      ws.onerror do |error|
        puts "WebSocket error: #{error}"
      end
    end
    
    puts "WebSocket server started on ws://0.0.0.0:8080"
    puts "Open the HTML page in your browser to see the demo"
  end
end

main if __FILE__ == $0

