export default class Event {
    constructor(id, image, title, dateTime, location, category, availablePlace, description, organizer){
        this.id = id;
        this.image = image;
        this.title = title;
        this.dateTime = dateTime;
        this.location = location;
        this.category = category;
        this.availablePlace = availablePlace;
        this.description = description;
        this.organizer = organizer;
    }
}