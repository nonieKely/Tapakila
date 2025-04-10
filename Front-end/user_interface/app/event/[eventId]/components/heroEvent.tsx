"use client"

import { Flex, Stack, Heading, Wrap, Image, Icon, Box } from "@chakra-ui/react";
import { FaLocationDot } from "react-icons/fa6";
import { FaClock } from "react-icons/fa";
import { FaUserCog } from "react-icons/fa";
import Event from "../../../../../../Back-end/api/entity/Event";
import Countdown from "./countDown";


export default function HeroEvent({ event }: { event: Event }) {
    return (
        <Flex justify="space-around" mb="10vh">
            <Image rounded="md" src={"/"+event.image} alt="Event image" htmlWidth="500px" htmlHeight="500px"></Image>

            <Flex gap="15vh" direction="column" width="50%">
                <Stack gap="6">
                    <Heading fontWeight="bold" size="5xl">{event.title}</Heading>
                    <Box>
                        <Heading fontWeight="normal" size="lg" color="yellow.400">{event.category}</Heading>
                    </Box>
                    <Flex >
                        <Icon fontSize="2xl">
                            <FaLocationDot />
                        </Icon>
                        <Heading fontWeight="medium" size="xl" ml="0.8vw">{event.location}</Heading>
                    </Flex>
                    <Flex >
                        <Icon fontSize="2xl">
                            <FaClock />
                        </Icon>
                        <Heading fontWeight="medium" size="xl" ml="0.8vw">{event.dateTime}</Heading>
                    </Flex>
                    <Flex >
                        <Icon fontSize="2xl">
                            <FaUserCog />
                        </Icon>
                        <Heading fontWeight="medium" size="xl" ml="0.8vw">{event.organizer || "Blake association"}</Heading>
                    </Flex>
                </Stack>
                <Wrap>
                    <Heading>TICKET PURCHASE LIMIT :</Heading>
                    <Countdown targetDate={event.dateTime} />
                </Wrap>
            </Flex>
        </Flex>
    )
}