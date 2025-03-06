import { Flex, Stack, Heading, Wrap, Image } from "@chakra-ui/react";

export default function HeroEvent() {
    return (
        <Flex justify="space-around">
            <Image rounded="md" src="https://bit.ly/dan-abramov" alt="Event image" htmlWidth="500px" htmlHeight="500px"></Image>

            <Flex gap="25vh" direction="column" width="50%">
                <Stack gap="6">
                    <Heading fontWeight="bold" size="5xl">Title</Heading>
                    <Heading fontWeight="normal" size="lg" border="2px solid" borderRadius="md" borderColor="yellow.400" w="7vw">Categories</Heading>
                    <Heading fontWeight="medium" size="xl">Place</Heading>
                    <Heading fontWeight="medium" size="xl">Date</Heading>
                    <Heading fontWeight="medium" size="xl">Organizer</Heading>
                </Stack>
                <Wrap>
                    COMPTEUR
                </Wrap>
            </Flex>
        </Flex>
    )
}