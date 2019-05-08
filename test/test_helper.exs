ExUnit.start()

Mox.defmock(Londibot.TFLMock, for: Londibot.TFLBehaviour)
Mox.defmock(Londibot.NotifierMock, for: Londibot.NotifierBehaviour)
Mox.defmock(Londibot.SubscriptionStoreMock, for: Londibot.StoreBehaviour)
