from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.image import Image
from kivy.uix.gridlayout import GridLayout
from kivy.graphics import Color, Rectangle

from gtts import gTTS
import os

class SparklingList(App):
    def build(self):
        # Main layout
        main_layout = BoxLayout(orientation='vertical')

        # Background color
        with main_layout.canvas.before:
            Color(0.2, 0.4, 0.6, 1)  # RGBA values for the background color
            Rectangle(pos=(0, 0), size=(main_layout.width, main_layout.height))

        # Image
        img = Image(source='/Users/ialvector/Desktop/Glurping Sunday.PNG')
        main_layout.add_widget(img)

        grid_layout = GridLayout(cols=2, spacing=10)
        grid_layout.add_widget(Button(text='Break down task', on_press=self.speak_hello))

        grid_layout.add_widget(Button(text='Vote Up/Down for sound effects'))
        grid_layout.add_widget(Button(text='Vote Up/Down for style swag'))
        grid_layout.add_widget(Button(text='Vote Up/Down for dance swag'))
        grid_layout.add_widget(Button(text='Vote Up/Down for music swag'))
        grid_layout.add_widget(Button(text='Vote Up/Down for Carbonator/s list'))
        main_layout.add_widget(grid_layout)
        return main_layout

    def speak_hello(self, instance):
        # Function to speak "Hello" using gTTS
        text_to_speak = "Hello"
        tts = gTTS(text=text_to_speak, lang='en')
        tts.save("hello.mp3")

        # Play the saved audio file
        os.system("open hello.mp3")

if __name__ == "__main__":
    SparklingList().run()
