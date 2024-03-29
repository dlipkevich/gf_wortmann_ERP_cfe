﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТекущийСтатус = Параметры.мсТекущийСтатус;
	
	мсАдресЭлектроннойПочты = Параметры.мсАдресЭлектроннойПочты;
	мсНомерЗаказа = Параметры.мсНомерЗаказа;
	
	ОбновитьДанныеАвторизацииНаСервере();
	
КонецПроцедуры

Функция ОбновитьДанныеАвторизацииНаСервере()
	
	Элементы.ДанныеАвторизации.Заголовок = "Данные авторизации: " + Символы.ПС
												+ " * Номер договора или заказа: " + мсНомерЗаказа + Символы.ПС
												+ " * Адрес эл. почты: " + мсАдресЭлектроннойПочты;
	
КонецФункции

&НаКлиенте
Процедура НаписатьОбращение(Команда)
	ЗапуститьПриложение("mailto:support@moscowsoft.com");
КонецПроцедуры

&НаКлиенте
Процедура УказатьНомерЗаказаАдресПочты(Команда)
	
	ПараметрыАвторизации = Новый Структура("мсНомерЗаказа, мсАдресЭлектроннойПочты", мсНомерЗаказа, мсАдресЭлектроннойПочты);
	ОткрытьФорму("ВнешняяОбработка.УниверсальныйОбменДаннымиXML.Форма.ФормаАвторизации",ПараметрыАвторизации, ЭтаФорма);
		
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		мсНомерЗаказа = ВыбранноеЗначение.мсНомерЗаказа;
		мсАдресЭлектроннойПочты = ВыбранноеЗначение.мсАдресЭлектроннойПочты;
		ОбновитьДанныеАвторизацииНаСервере();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	ЭтаФорма.ЗакрыватьПриВыборе = Истина;
	ОповеститьОВыборе(Новый Структура("мсНомерЗаказа, мсАдресЭлектроннойПочты", мсНомерЗаказа, мсАдресЭлектроннойПочты));
КонецПроцедуры
