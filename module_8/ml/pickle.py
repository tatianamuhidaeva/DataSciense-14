from sklearn.linear_model import LinearRegression
from sklearn.datasets import load_diabetes
import numpy as np
import pickle

X, y = load_diabetes(return_X_y=True)
X = X[:, 0].reshape(-1, 1) # Берём только один признак и переведем строку в столбец
regressor = LinearRegression()
regressor.fit(X,y)

value_to_predict = np.array([0.04]).reshape(-1, 1)
regressor.predict(value_to_predict)
with open('myfile.pkl', 'wb') as output:
  pickle.dump(regressor, output)