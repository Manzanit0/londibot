# https://hexdocs.pm/mox/Mox.html#module-compile-time-requirements
Mox.defmock(Londibot.TFLMock, for: Londibot.TFLBehaviour)
Mox.defmock(Londibot.NotifierMock, for: Londibot.NotifierBehaviour)
Mox.defmock(Londibot.SubscriptionStoreMock, for: Londibot.StoreBehaviour)
