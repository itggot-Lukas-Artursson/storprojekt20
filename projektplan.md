# Projektplan

## 1.Projektbeskrivning (Beskriv vad sidan ska kunna göra)
Sidan är ett forum för allt som har med matlagning att göra. Du som användare kan skapa inlägg i olika kategorier, svara på olika trådar och som adin kan du skapa kategorier där olika trådar ligger.
## 2. Vyer (visa bildskisser på dina sidor)
Jag placerade skissen och ER-diagramet utanför eftersom jag inte vet ur man får in bilder här.

## 3. Databas med ER-diagram (Bild)
## 4. Arkitektur (Beskriv filer och mappar - vad gör/inehåller de?)

I min Views mapp ligger mapparna categories, answer, posts och user layout.slim. Den är offentlig och innehåller därför inte app.rb eller model.rb.

categories innehåller get_posts.slim där man kan skapa sin egna post och klicka sig in på andra posts. Den innheåler också index.slim som är en landing page. Den innehåller också new.slim där man skapar sin egna category som admin. 

posts innehåller add_category.slim som kopplar en post till flera kategorier. Den innhåller också edit.slim där man ändrar sin redan skrivna post. Och new.slim som skapar din egna post. Den innehller även thread.slim som visar upp hela tråden där an som anvädare kan läsa vad som skrivits om en post.

answer innheåller edit.slim som gör att en skrivet svar på ett inlägg kan man ändra om man själv skrivit inlägget

User innheåller login.slim som är sidan du kommer tll om man vill loga in. Registrer.slim hamnar du vid registering av nytt konto.

layout.slim innhåller sådant som ska finnas på alla sidor på hemsidan.
