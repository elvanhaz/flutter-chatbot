# save this as app.py

from flask import Flask, jsonify, request
from main import chatWithBot

app = Flask(__name__)

@app.route("/chat", methods=['GET','POST'])
def chatBot():
    chatInput = request.form.get('chatInput')
    return jsonify(chatBotReply=chatWithBot(chatInput))

if __name__ == '__main__':
    app.run(debug=True)
