from flask import Flask
import os, re, json, time
from twilio.rest import TwilioRestClient
import twilio
import twilio.twiml
from datetime import datetime
from flask import Flask, request, render_template, redirect, jsonify, send_file, url_for

app = Flask(__name__)
app.config['DEBUG'] = os.environ['DEBUG']

# Twilio setup
account = os.environ['TWILIO_SID']
token = os.environ['TWILIO_AUTH']
twilio_number = os.environ['TWILIO_NUM']
client = TwilioRestClient(account, token)
destination_phone_number = '+14155581001'
button_sequence_for_human = 'www1ww1ww2'
message_to_user = "I'm on it! I'll call you when I reach a human."
ready_to_connect_message = "Okay! I have a human on the other line. I'm going to call you right now."
hangup_message = "Hmmm, it looks they hung up on you. How rude. Reply CONNECT to try again."
user_number = ''

@app.route("/", methods = ['GET', 'POST'])
def index():
  body = request.values.get('Body').strip().lower()
  if body == 'connect':
    global user_number
    user_number = request.values.get('From')
    call = client.calls.create(to = destination_phone_number,
                              from_ = twilio_number,
                              send_digits = button_sequence_for_human,
                              url = url_for('call_answered', _external=True))
    
    message = client.messages.create(to = user_number,
                                    from_ = twilio_number,
                                    body = message_to_user)
  print call.sid
  return 'calling...'

@app.route("/call-answered", methods = ['GET', 'POST'])
def call_answered():
  resp = twilio.twiml.Response()
  with resp.gather(numDigits=1, action="/handle-key", method="POST") as g:
    g.pause(length = 3)
    g.play("https://s3-us-west-1.amazonaws.com/cfa-health-connect/leo.wav", loop=0)
  return str(resp)

@app.route("/handle-key", methods = ['GET', 'POST'])
def handle_key():
  digit_pressed = request.values.get('Digits', None)
  if digit_pressed:
    message = client.messages.create(to = user_number,
                                    from_ = twilio_number,
                                    body = ready_to_connect_message)
    resp = twilio.twiml.Response()
    resp.dial(user_number)
    return str(resp)

  # If the answer-er doesn't press anything, apologize to the client
  else:
    message = client.messages.create(to = user_number,
                                    from_ = twilio_number,
                                    body = hangup_message)

if __name__ == "__main__":
  app.run()