#ifndef PERIPHERALS_HPP
#define PERIPHERALS_HPP

#include "helper.hpp"

class input_peripheral {
    protected:
        volatile const unsigned int * const address;
        const unsigned int mask;
    
        public:
            /**
             * @brief Construct a new input_peripheral object
             * 
             * @param number Which index of the input_peripheral
             * @param address Which input_peripheral base address
             */
            input_peripheral(volatile const unsigned int * const address, unsigned int number):address(address),mask(1u << number){}
            /**
             * @brief Checks if input_peripheral is active
             * 
             * @return `true` when the input_peripheral is active
             */
            bool active() const {
                return (*address & mask) != 0;
            }
};

class Button : public input_peripheral {
    public:
        /**
         * @brief Construct a new Button object
         * 
         * @param number Which Button to monitor from 0-3
         */
        Button(unsigned int number)
        : input_peripheral(
            (volatile const unsigned int * const)0x80000004,
            number
        ){}
};


class Switch : public input_peripheral {
    public:
        /**
         * @brief Construct a new Switch object
         * 
         * @param number Which Switch to monitor from 0-3
         */
        Switch(unsigned int number)
        : input_peripheral(
            (volatile const unsigned int * const)0x80000000,
            number
        ){}
};

class Leds {
    private:
        volatile unsigned int * const address = (volatile unsigned int *)0x80000008;
        unsigned int value = 0;

        void write() {
            *address = value;
        }

    public:
        /**
         * @brief Checks if LED[number] is active
         * 
         * @return true if LED[number] is active
         */
        bool active(unsigned int number) const {
            return (value & (1u << number)) != 0;
        }

        /**
         * @brief Turns on LED[number] 
         * 
         */
        void activate(unsigned int number) {
            value |= 1u << number;
            write();
        }

        /**
         * @brief Turns off LED[number]
         * 
         */
        void deactivate(unsigned int number) {
            value &= ~(1u << number);
            write();
        }

        /**
         * @brief Toggle LED[number]'s state
         * 
         */
        void toggle(unsigned int number) {
            value ^= 1u << number;
            write();
        }
};

class Pmod {
    private:
        volatile unsigned char * address_in;
        volatile unsigned char * address_out;
        volatile unsigned char * address_dir;

    public:

        /**
         * @brief Construct a new Pmod object
         * 
         * @param which Pmod selector a-d
         */
        Pmod(const char which) {
            address_in = (volatile unsigned char *)(0x8000000c + ((to_lower(which) - 'a') << 2));
            address_out = (volatile unsigned char *)(0x8000000d + ((to_lower(which) - 'a') << 2));
            address_dir = (volatile unsigned char *)(0x8000000e + ((to_lower(which) - 'a') << 2));
        }

        /**
         * @brief Set the dir object
         * 
         * @param direction Each bit corresponds to a pin of the pmod 1 == out, 0 == in
         */
        void set_dir(const unsigned char direction) {
            *address_dir = direction;
        }

        /**
         * @brief Write to the pmod if writable
         * 
         * @param out bits to output
         */
        void write(const unsigned char out) {
            *address_out = out;
        }

        /**
         * @brief Read from pmod if readable
         * 
         * @return char Input bits
         */
        char read() {
            return *address_in;
        }
};

#endif // PERIPHERALS_HPP