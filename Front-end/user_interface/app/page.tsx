"use client"

import {
  Box,
  createListCollection,
  Grid,
  Heading,
} from "@chakra-ui/react"

import {
  SelectContent,
  SelectItem,
  SelectLabel,
  SelectRoot,
  SelectTrigger,
  SelectValueText,
} from "@/components/ui/select"

import { useEffect, useState } from "react";
import EventsList from "./components/events-list";

import Event from "../../../Back-end/api/entity/Event.js"
import getSearchedEvent from "@/lib/events/getSearchedEvents";
import { useSearchParams } from 'next/navigation';
import getAllCategories from "@/lib/events/getAllCategories";
import getAllLocations from "@/lib/events/getAllLocations";
import UpdatePastEvents from "@/lib/events/updatePastEvents";

export default function Page() {
  const [data, setData] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const searchParams = useSearchParams();
  const parametre = searchParams.get('title');


  const [selectedDate, setSelectedDate] = useState<string[]>(["Upcoming"])
  const [selectedPlace, setSelectedPlace] = useState<string[]>(["All"])
  const [selectedCategory, setSelectedCategory] = useState<string[]>(["All"])
  const [categories, setCategories] = useState(createListCollection<{label: string; value: string;}>({ items: [] }))
  const [locations, setLocations] = useState(createListCollection<{label: string; value: string;}>({ items: [] }))

  useEffect(() => {
    async function fetchData() {
      try {
        await UpdatePastEvents();
        try {
          const result = await getSearchedEvent(parametre || "");
        setData(result);

        const categoriesFetch = await getAllCategories();
        setCategories(createListCollection({ items: categoriesFetch }));

        const locationsFetch = await getAllLocations();
        setLocations(createListCollection({ items: locationsFetch }));
        } catch (error) {
          console.error(error)
        }
      } catch (error) {
        console.error("Erreur de chargement", error);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [parametre]);

  const filteredAndSortedEvents = filterAndSortEvents(data, selectedDate, selectedPlace, selectedCategory);

  if (loading) return (<Box display={"flex"} flexDirection={"column"} alignItems={"center"} alignContent={"center"} justifyContent={"center"} w={"100%"} h={"78.65dvh"}><Heading size={"3xl"}>Loading . . .</Heading></Box>);

  return (
    <>
      <Grid templateColumns="repeat(auto-fit, minmax(200px, 1fr))" gap={3} padding="1" mt={"3"} alignItems={"center"} justifyContent={"center"}>
        <Heading size={"2xl"} marginLeft={"5"} marginRight={"1"}>Upcoming events</Heading>
        <Box display="flex" gap="4" alignItems={"center"}>
          <SelectRoot
            collection={dates}
            width="320px"
            value={selectedDate}
            onValueChange={(e) => {setSelectedDate(e.value)}}
          >
            <SelectLabel>Date</SelectLabel>
            <SelectTrigger>
              <SelectValueText placeholder="Select date" />
            </SelectTrigger>
            <SelectContent>
              {dates.items.map((date) => (
                <SelectItem item={date} key={date.value}>
                  {date.label}
                </SelectItem>
              ))}
            </SelectContent>
          </SelectRoot>
        </Box>
        <Box display="flex" gap="4" alignItems={"center"}>
          <SelectRoot
            collection={locations}
            width="320px"
            value={selectedPlace}
            onValueChange={(e) => setSelectedPlace(e.value)}
          >
            <SelectLabel>Place</SelectLabel>
            <SelectTrigger>
              <SelectValueText placeholder="Select place" />
            </SelectTrigger>
            <SelectContent>
              {locations.items.map((location) => (
                <SelectItem item={location} key={location.value}>
                  {location.label}
                </SelectItem>
              ))}
            </SelectContent>
          </SelectRoot>
        </Box>
        <Box display="flex" gap="4" alignItems={"center"}>
          <SelectRoot
            collection={categories}
            width="320px"
            value={selectedCategory}
            onValueChange={(e) => setSelectedCategory(e.value)}
          >
            <SelectLabel>Category</SelectLabel>
            <SelectTrigger>
              <SelectValueText placeholder="Select category" />
            </SelectTrigger>
            <SelectContent>
              {categories.items.map((category) => (
                <SelectItem item={category} key={category.value}>
                  {category.label}
                </SelectItem>
              ))}
            </SelectContent>
          </SelectRoot>
        </Box>
      </Grid>
      
      {/* List of events */}

      <EventsList events={filteredAndSortedEvents} />
    </>
  )
}

const dates = createListCollection({
  items: [
    { label: "Upcoming", value: "Upcoming" },
    { label: "Latest", value: "Latest" },
  ],
})

function filterAndSortEvents(events: Event[], dateOrder: string[], locationFilter: string[], categoryFilter: string[]): Event[] {
  let organizedData: Event[] = events;

  if (locationFilter[0] !== "All") {
    organizedData = organizedData.filter(event => event.location === locationFilter[0]);
  }

  if (categoryFilter[0] !== "All") {
    organizedData = organizedData.filter(event => event.category === categoryFilter[0]);
  }

  if (dateOrder[0] === "Latest") {
    organizedData = organizedData.sort((a, b) =>
      new Date(b.dateTime.replace(" ", "T")).getTime() - new Date(a.dateTime.replace(" ", "T")).getTime()
    );
  } else {
    organizedData = organizedData.sort((a, b) =>
      new Date(a.dateTime.replace(" ", "T")).getTime() - new Date(b.dateTime.replace(" ", "T")).getTime()
    );
  }

  return organizedData;
}