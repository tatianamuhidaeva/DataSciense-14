import numpy as np
import pickle

from flask import Flask, request

app = Flask(__name__)

with open('model.pkl', 'rb') as pkl_file:
    model_from_file = pickle.load(pkl_file)
    
def model_predict(value):
    """
    Трансформирует входное значение в подходящее для модели
    и делает предсказание.    
    """
    value_to_predict = np.array([float(value)]).reshape(-1, 1)
    prediction = model_from_file.predict(value_to_predict)[0]
    return prediction

@app.route('/predict')
def hello_func():
    """
    Извлекает входной аргумент 'value', передает его модели
    и печатает на экране предсказание
    
    Проверяет входное значение, выдает ошибку,
    если это не число
    """
    value = request.args.get('value')
    try:
        prediction = model_predict(value)
        return f'the result is {prediction}!'
    except Exception as e:
        return f'prediction failed with error {e}'


if __name__ == '__main__':
    app.run('localhost', 5000)
    
    
"""
Как проверить, что к серверу есть доступ по API:

В командной строке можно выполнить вызов к серверу, например, с помощью curl:

curl -X GET 'localhost:5000/predict?value=3'

Если все хорошо, то в ответ вы получите результат. В случае с этим кодом, результат будет такой:
the result is 1064.6827077477801!
"""