
import pickle
from flask import Flask, request
# request нужен для получения параметров запроса
app = Flask(__name__)  # создадим объект Flask-приложения

# загрузим модель
with open('model.pkl', 'rb') as pkl_file:
    regressor_from_file = pickle.load(pkl_file)

# обработаем путь predict | Предсказание по двум критериям
@app.route('/predict')
def hello_func():
    echo = ''
    bmi = 0
    s5 = 0
    bmi_new = request.args.get('bmi')
    s5_new = request.args.get('s5')
    try:
        bmi = float(bmi_new)
    except ValueError:
        echo += 'bmi is not a number!' + '<br>'
    
    try:
        s5 = float(s5_new)
    except ValueError:
        echo += 's5 is not a number!' + '<br>'    


    echo +=  'for bmi = ' + str(bmi) + '<br>'
    echo +=  'for s5 = ' + str(s5) + '<br>'

    prediction = regressor_from_file.predict([[bmi,s5]])
    echo += 'the result is ' + str(prediction)
    return echo


# запускаем сервер
if __name__ == '__main__':
    app.run('localhost', 5000)    


