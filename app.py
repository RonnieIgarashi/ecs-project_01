from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello from ecs-project_01 (Flask)"


@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    app.run(debug=True)
