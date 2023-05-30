from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import os
current_dir = os.path.dirname(os.path.realpath(__file__))

app = Flask(__name__)

# Load the model and tokenizer
tokenizer = AutoTokenizer.from_pretrained(os.path.join(current_dir, "model"))
model = AutoModelForSequenceClassification.from_pretrained(os.path.join(current_dir, "model"))

@app.route("/predict", methods=['POST'])
def predict():
    # Get the text from the POST request
    text = request.json['text']

    # Encode the text and make a prediction
    inputs = tokenizer.encode_plus(text, return_tensors='pt')
    output = model(**inputs)
    scores = output[0][0].detach().numpy()
    # Assuming you are using sigmoid in your model, convert logits to probabilities
    sigmoid = torch.nn.Sigmoid()
    probabilities = sigmoid(torch.from_numpy(scores)).tolist()

    return jsonify(probabilities)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
