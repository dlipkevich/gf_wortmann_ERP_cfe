﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	// ++ Галфинд СадомцевСА 21.11.2022 реквизит формы "гф_ТоварыВКоробах" используется в отчете гф_ОстаткиНоменклатуры
	Если ИмяФормы = "ВнешнийОтчет.гф_ОстаткиНоменклатуры.Форма"
		ИЛИ ИмяФормы = "Отчет.гф_ОстаткиНоменклатуры.Форма" Тогда
		ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");

		ДобавляемыеРеквизиты = Новый Массив;
	
		РеквизитФормы_гф_ТоварыВКоробах	= Новый РеквизитФормы("гф_ТоварыВКоробах", ОписаниеТиповБулево);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ТоварыВКоробах);
	
		ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	КонецЕсли;
	// -- Галфинд СадомцевСА 21.11.2022
КонецПроцедуры

&НаСервере
Процедура гф_ПриЗагрузкеВариантаНаСервереПосле(Настройки)
	// ++ Галфинд СадомцевСА 21.11.2022 реквизит формы "гф_ТоварыВКоробах" используется в отчете гф_ОстаткиНоменклатуры
	Если Не ИмяФормы = "ВнешнийОтчет.гф_ОстаткиНоменклатуры.Форма"
		И Не ИмяФормы = "Отчет.гф_ОстаткиНоменклатуры.Форма" Тогда
		Возврат;
	КонецЕсли;
	Если КлючТекущегоВарианта = "ОстаткиКоробнойСклад"
		ИЛИ КлючТекущегоВарианта = "ОстаткиНоменклатурыКоробнойСклад" Тогда
		гф_ТоварыВКоробах = Истина;
	Иначе
		гф_ТоварыВКоробах = Ложь;
	КонецЕсли;
	Если ИмяФормы = "Отчет.гф_ОстаткиНоменклатуры.Форма" Тогда
		Возврат;
	КонецЕсли;
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	Для Каждого ВариантНастройки Из ОтчетОбъект.СхемаКомпоновкиДанных.ВариантыНастроек Цикл
		Если ВариантНастройки.Имя = КлючТекущегоВарианта Тогда
			НастройкиОтчета.Наименование = ВариантНастройки.Представление;
		КонецЕсли;
	КонецЦикла;
	// -- Галфинд СадомцевСА 21.11.2022
КонецПроцедуры

#КонецОбласти
