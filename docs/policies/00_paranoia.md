# Be Paranoid

As shown by GrapheneOS and QubesOS, the best security management is done by those who trust none and layer their defences. Arcanyx works on the principle that every lock can and will be broken to assume that no cryptographical algorithm nor their encapsulation is safe, but stops short of full on TempleOS security philosophy to rather try to cooperate with the available solutions as that is seen as having more impact then single person / small group re-implementing everything from the ground though would result in an interesting experiment.

### Mandates

* M.1. Always implement secret rotation method, every key can be invalid at any point and the infrastructure is expected to automatically refresh secrets to try to mitigate for it.
* M.2. Randomly refresh keys at minimum every 1 hour provided that the energy efficiency and service integration allows it, if not be prepared to lower it and implement to the minimal supported value.

### TODO
* Consider standalone server for secret rotation
