﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОк(Команда)
	
	Контрагент = СписокКонтрагентов;
	Закрыть();

КонецПроцедуры

&НаКлиенте
Процедура Подбор(Команда)
	
	ПараметрыПодбора = новый Структура("ЗакрыватьПриВыборе, ЗакрыватьПриЗакрытииВладельца", Ложь, Истина);
	ОткрытьФорму("Справочник.Контрагенты.ФормаВыбора", ПараметрыПодбора, ЭтаФорма, "СправочникКонтрагентыФормаВыбора");

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ЗначениеВыбора, Источник)
	
	Если ТипЗнч(ЗначениеВыбора) = Тип("СправочникСсылка.Контрагенты") и СписокКонтрагентов.НайтиПоЗначению(ЗначениеВыбора) = Неопределено Тогда
		СписокКонтрагентов.Добавить(ЗначениеВыбора);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
