﻿

&НаКлиенте
Процедура ВыполнитьСопоставление(Команда)
	ВыполнитьСопоставлениеНаСервере();
КонецПроцедуры

&НаСервере
Процедура ВыполнитьСопоставлениеНаСервере()
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.ВыполнитьСопоставлениеПрОрдеровИЗаявокНаВозврат();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Отказ = Истина;
	ПоказатьПредупреждение( , 
	"Перейдите в регламентное задание!
	|Не предусмотрено открытие формы обработки!", 
	10, 
	"Обработка ""Сопоставление приходных ордеров и заявок на возврат""");
КонецПроцедуры

