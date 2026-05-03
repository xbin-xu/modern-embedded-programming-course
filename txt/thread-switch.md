
# Thread Switch in RTOS

> [@#22 RTOS Part-1: What is a Real-Time Operating System?]

## Save(r0\~R3, R12, R14-LR, R15-PC, xPSR)

```c
#define THREAD_STACK_MAX (40u)
#define THREAD_STACK_INIT(ptr, pc)                                             \
  do {                                                                         \
    *(--ptr) = (1u << 24);                                                     \
    *(--ptr) = (uint32_t)(pc);                                                 \
    *(--ptr) = (14);                                                           \
    *(--ptr) = (12);                                                           \
    *(--ptr) = (3);                                                            \
    *(--ptr) = (2);                                                            \
    *(--ptr) = (1);                                                            \
    *(--ptr) = (0);                                                            \
  } while (0)

uint32_t thread_stack_1[THREAD_STACK_MAX];
uint32_t thread_stack_2[THREAD_STACK_MAX];
uint32_t *thread_1_sp = &thread_stack_1[THREAD_STACK_MAX];
uint32_t *thread_2_sp = &thread_stack_2[THREAD_STACK_MAX];

void thread_1(void)
{
  while (1) {
    printf("1\n");
    HAL_Delay(1000);
  }
}

void thread_2(void)
{
  while (1) {
    printf("2\n");
    HAL_Delay(1000);
  }
}

void SysTick_Handler(void)
{
  uwTick += uwTickFreq;
}

int main(void) {
  // ...
  THREAD_STACK_INIT(thread_1_sp, &thread_1);
  THREAD_STACK_INIT(thread_2_sp, &thread_2);
  while (1) {
  }
}
```

```sh
thread_stack_1: [0x200000B0, 0x20000150)
thread_stack_2: [0x20000150, 0x200001F0)
thread_1_sp: 0x20000150
thread_2_sp: 0x200001F0
MSP: 0x200005F0

main: MSP(0x200005D8, main), thread_1_sp(0x20000130), thread_2_sp(0x200001D0)
|   0. Try to switch thread_1
|   1. Set breakpoint at before SysTick_Handler return: MSP(0x200005B8)
|   2. Save current stack frame and switch: MSP = thread_1_sp;
|   => MSP(0x20000130), thread_1_sp(0x20000130), thread_2_sp(0x200001D0)
V
thread_1: MSP(0x20000150), thread_1_sp(0x20000130), thread_2_sp(0x200001D0)
|   0. Try to switch thread_2
|   1. Set breakpoint at before SysTick_Handler return: MSP(0x20000120)
|   2. Save current stack frame and switch: thread_1_sp = MSP; MSP = thread_2_sp;
|   => MSP(0x200001D0), thread_1_sp(0x20000120), thread_2_sp(0x200001D0)
V
thread_2: MSP(0x200001F0), thread_1_sp(0x20000120), thread_2_sp(0x200001D0)
|   0. Try to switch thread_1
|   1. Set breakpoint at before SysTick_Handler return: MSP(0x200001C0)
|   2. Save current stack frame and switch: thread_2_sp = MSP; MSP = thread_1_sp;
|   => MSP(0x20000120), thread_1_sp(0x20000120), thread_2_sp(0x200001C0)
V
thread_1: MSP(0x20000140), thread_1_sp(0x20000120), thread_2_sp(0x200001C0)
    0. Try to switch thread_2
    1. Set breakpoint at before SysTick_Handler return: MSP(0x20000120)
    2. Save current stack frame and switch: thread_1_sp = MSP; MSP = thread_2_sp;
    => MSP(0x200001C0), thread_1_sp(0x20000120), thread_2_sp(0x200001C0)
```

## Save(r4\~R11, r0\~R3, R12, R14-LR, R15-PC, xPSR)

```c
#define THREAD_STACK_MAX (40u)
#define THREAD_STACK_INIT(ptr, pc)                                             \
  do {                                                                         \
    *(--ptr) = (1u << 24);                                                     \
    *(--ptr) = (uint32_t)(pc);                                                 \
    *(--ptr) = (14);                                                           \
    *(--ptr) = (12);                                                           \
    *(--ptr) = (3);                                                            \
    *(--ptr) = (2);                                                            \
    *(--ptr) = (1);                                                            \
    *(--ptr) = (0);                                                            \
    *(--ptr) = (11);                                                           \
    *(--ptr) = (10);                                                           \
    *(--ptr) = (9);                                                            \
    *(--ptr) = (8);                                                            \
    *(--ptr) = (7);                                                            \
    *(--ptr) = (6);                                                            \
    *(--ptr) = (5);                                                            \
    *(--ptr) = (4);                                                            \
  } while (0)

uint32_t thread_stack_1[THREAD_STACK_MAX];
uint32_t thread_stack_2[THREAD_STACK_MAX];
uint32_t *thread_1_sp = &thread_stack_1[THREAD_STACK_MAX];
uint32_t *thread_2_sp = &thread_stack_2[THREAD_STACK_MAX];

void thread_1(void)
{
  while (1) {
    printf("1\n");
    HAL_Delay(1000);
  }
}

void thread_2(void)
{
  while (1) {
    printf("2\n");
    HAL_Delay(1000);
  }
}

void SysTick_Handler(void)
{
  uwTick += uwTickFreq;
}

int main(void) {
  // ...
  THREAD_STACK_INIT(thread_1_sp, &thread_1);
  THREAD_STACK_INIT(thread_2_sp, &thread_2);
  while (1) {
  }
}
```

```sh
thread_stack_1: [0x200000B0, 0x20000150)
thread_stack_2: [0x20000150, 0x200001F0)
thread_1_sp: 0x20000150
thread_2_sp: 0x200001F0
MSP: 0x200005F0

main: MSP(0x200005D8, main), thread_1_sp(0x20000110), thread_2_sp(0x200001B0)
|   0. Try to switch thread_1
|   1. Set breakpoint at before SysTick_Handler return: MSP(0x200005B8)
|   2. Save current stack frame and switch: MSP = thread_1_sp + 0x20;
|   => MSP(0x20000130), thread_1_sp(0x20000110), thread_2_sp(0x200001B0)
V
thread_1: MSP(0x20000150), thread_1_sp(0x20000110), thread_2_sp(0x200001B0)
|   0. Try to switch thread_2
|   1. Set breakpoint at before SysTick_Handler return: MSP(0x20000120)
|   2. Save current stack frame and switch: MSP -= 0x20; copy_from_to(R4~R11, MSP); thread_1_sp = MSP; MSP = thread_2_sp + 0x20
|   => MSP(0x200001D0), thread_1_sp(0x20000100), thread_2_sp(0x200001B0)
V
thread_2: MSP(0x200001F0), thread_1_sp(0x20000120), thread_2_sp(0x200001B0)
|   0. Try to switch thread_1
|   1. Set breakpoint at before SysTick_Handler return: MSP(0x200001C0)
|   2. Save current stack frame and switch: MSP -= 0x20; copy_from_to(R4~R11, MSP); thread_2_sp = MSP; copy_from_to(thread_1_sp, R4~R11) MSP = thread_1_sp + 0x20
|   => MSP(0x20000120), thread_1_sp(0x20000100), thread_2_sp(0x200001A0)
V
thread_1: MSP(0x20000140), thread_1_sp(0x20000100), thread_2_sp(0x200001A0)
    0. Try to switch thread_2
    1. Set breakpoint at before SysTick_Handler return: MSP(0x20000120)
|   2. Save current stack frame and switch: MSP -= 0x20; copy_from_to(R4~R11, MSP); thread_1_sp = MSP; copy_from_to(thread_2_sp, R4~R11) MSP = thread_2_sp + 0x20
    => MSP(0x200001C0), thread_1_sp(0x20000100), thread_2_sp(0x200001A0)
```

[@#22 RTOS Part-1: What is a Real-Time Operating System?]: https://www.state-machine.com/video-course
