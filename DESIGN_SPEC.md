# Siko UI Design Specification

## Visual direction

Arabic-first, friendly, modern, rounded Material 3 interface.
The visual language uses a soft light background, cards with large rounded corners, a purple-indigo seed color, clear icons, and a large central avatar.

## Screen 01 — Profile Setup

Purpose: first-run identity and assistant setup.

Elements:
- User name
- Assistant name
- Learning language: English / French
- English variety: American / British
- Avatar selector
- Default animated robot
- Save / start CTA

## Screen 02 — Home

Purpose: one-tap access to the main experiences.

Hero:
- Greeting with user name
- Large avatar
- Quick action: Voice chat
- Quick action: Text chat

Feature cards:
- Learn English
- Learn French
- Tell Siko about your day

## Screen 03 — Learning

Purpose: language learning home.

Elements:
- Language switcher
- Current level/progress
- Daily lesson
- Listen to example
- Start exercise
- Learning paths: pronunciation, vocabulary, grammar, real-life situations

## Screen 04 — Chat

Purpose: free conversation.

Elements:
- Siko avatar in app bar
- User/assistant message bubbles
- Voice replay on assistant messages
- Text composer
- Send button

## Screen 05 — Voice Chat

Purpose: live voice interaction.

States:
- Idle
- Listening
- Thinking
- Speaking

Elements:
- Large animated avatar
- Transcript
- AI response
- Microphone action button
- Current speech locale

## Screen 06 — Settings

Purpose: change profile and see technical state.

Elements:
- Current avatar and profile
- Edit profile
- AI mode indicator
- Privacy note
- Voice note
- About dialog

## Avatar behavior

The default avatar is a vector robot drawn with CustomPainter, so it needs no image asset.

A custom gallery image can replace it at runtime. The same animation states remain around the image. Later, add true lip-sync and expression layers without changing the navigation structure.
