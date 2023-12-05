﻿
#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ПрименятьНаценки", Объект.ПрименятьНаценки);
	
	Элементы.Наценки.Видимость = Объект.ПрименятьНаценки;
	
	ДатаДляРТУ = ТекущаяДатаСеанса();
	ЦифровойКодВалюты = "978";
	КурсЕвро = ПолучитьКурсЕвро(ДатаДляРТУ, ЦифровойКодВалюты);
	ЗаполнитьТЧСкидкиПоЗаказам();
	ЗаполнитьТЧСкидки();
	ЗаполнитьТЧНаценки(); 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧСкидкиПоЗаказам()
	Для Каждого ЭлементМассива Из Параметры.СкидкиПоЗаказам Цикл
		нс = Объект.СкидкиПоЗаказам.Добавить();
		ЗаполнитьЗначенияСвойств(нс, ЭлементМассива);
	КонецЦикла;
	Для Каждого ЭлементМассива Из Параметры.МассивЗаказы Цикл
		СтрокиПоЗаказу = Объект.СкидкиПоЗаказам.НайтиСтроки(Новый Структура("Заказ", ЭлементМассива));
		Если СтрокиПоЗаказу.Количество() = 0 Тогда
			нс = Объект.СкидкиПоЗаказам.Добавить();
			нс.Заказ = ЭлементМассива;
		КонецЕсли;
	КонецЦикла;
	Для Каждого нс Из Объект.СкидкиПоЗаказам Цикл
		Если ЗначениеЗаполнено(нс.Заказ.Склад) Тогда
			нс.КоробнойСклад = ЭтоТоварыВКоробах(нс.Заказ.Склад);
		КонецЕсли;
		нс.СезонныйЗаказ = нс.Заказ.гф_СезонныйЗаказ;
		нс.КоличествоДнейОтсрочкиПлатежа = НайтиКоличествоДнейОтсрочкиПлатежа(нс.Заказ.Договор);
		мКоличествоДнейОтсрочкиПлатежа = нс.КоличествоДнейОтсрочкиПлатежа;
		мОрганизация = нс.Заказ.Организация;
		мКонтрагент = нс.Заказ.Контрагент;
		мДоговор = нс.Заказ.Договор;
		мСезонныйЗаказ = нс.Заказ.гф_СезонныйЗаказ;
	КонецЦикла;
	Объект.СкидкиПоЗаказам.Сортировать("Заказ");
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧСкидки()
	ТаблицаСкидок = Новый ТаблицаЗначений;
	ТаблицаСкидок.Колонки.Добавить("ВидСкидки");
	ТаблицаСкидок.Колонки.Добавить("Порядок");
	
	// добавляем скидки из регистра гф_ДопустимыеЗначенияСкидок
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_ДопустимыеЗначенияСкидок.ВидСкидки КАК ВидСкидки
	               |ИЗ
	               |	РегистрСведений.гф_ДопустимыеЗначенияСкидок КАК гф_ДопустимыеЗначенияСкидок
	               |ГДЕ
	               |	гф_ДопустимыеЗначенияСкидок.ИспользоватьДляРТУ
	               |	И НЕ гф_ДопустимыеЗначенияСкидок.ВидСкидки В(&ВидыСкидок)";
	Запрос.УстановитьПараметр("ВидыСкидок", Объект.Скидки.Выгрузить().ВыгрузитьКолонку("ВидСкидки"));
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если ТаблицаСкидок.Найти(Выборка.ВидСкидки, "ВидСкидки") = Неопределено Тогда
			СтрокаСкидки = ТаблицаСкидок.Добавить();
			СтрокаСкидки.ВидСкидки = Выборка.ВидСкидки;
			СтрокаСкидки.Порядок = ?(СтрокаСкидки.ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаПредоплату, 0, 1);
		КонецЕсли;
	КонецЦикла;
	ТаблицаСкидок.Сортировать("Порядок");
	
	СкидкаЗаПредоплату = 0;
	Для Каждого СтрокаСкидки Из ТаблицаСкидок Цикл
		СтруктураПоиска = Новый Структура("ВидСкидки", СтрокаСкидки.ВидСкидки);
		СтрокиПоЗаказу = Объект.Скидки.НайтиСтроки(СтруктураПоиска);
		Если СтрокиПоЗаказу.Количество() = 0 Тогда
			нс = Объект.Скидки.Добавить();
			нс.ВидСкидки = СтрокаСкидки.ВидСкидки;
			нс.СкидкаРасчетная = ПолучитьРасчетнуюСкидкуПоЗаказу(нс.ВидСкидки, ДатаДляРТУ, КурсЕвро, СкидкаЗаПредоплату);
			нс.СкидкаДляРТУ = нс.СкидкаРасчетная;
			нс.СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(нс.ВидСкидки, ДатаДляРТУ);
		КонецЕсли;
	КонецЦикла;
	Объект.Скидки.Сортировать("ВидСкидки");
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧНаценки()

	Объект.Наценки.Очистить();
	
	Если Объект.ПрименятьНаценки Тогда    
		
		Запрос = Новый Запрос;
		
		Запрос.Текст = "ВЫБРАТЬ
		|	гф_НаценкиЗаКурсСрезПоследних.КурсДо КАК КурсДо,
		|	гф_НаценкиЗаКурсСрезПоследних.ПроцентНаценки КАК ПроцентНаценки
		|ПОМЕСТИТЬ ВТ_Наценки
		|ИЗ
		|	РегистрСведений.гф_НаценкиЗаКурс.СрезПоследних(
		|			&ДатаДляРТУ,
		|			Сезон = &Сезон
		|				И КурсДо >= &КурсДо) КАК гф_НаценкиЗаКурсСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МИНИМУМ(ВТ_Наценки.КурсДо) КАК КурсДо
		|ПОМЕСТИТЬ ВТ_Курс
		|ИЗ
		|	ВТ_Наценки КАК ВТ_Наценки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВТ_Курс.КурсДо КАК КурсДо,
		|	ВТ_Наценки.ПроцентНаценки КАК ПроцентНаценки
		|ИЗ
		|	ВТ_Курс КАК ВТ_Курс
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Наценки КАК ВТ_Наценки
		|		ПО ВТ_Курс.КурсДо = ВТ_Наценки.КурсДо";    
		
		мКурсЕвро = Окр(КурсЕвро * 2) / 2;
		
		Запрос.Параметры.Вставить("КурсДо",		мКурсЕвро);
		Запрос.Параметры.Вставить("ДатаДляРТУ",	ДатаДляРТУ);
		Запрос.Параметры.Вставить("Сезон",		мДоговор.гф_Сезон);
		
		Результат = Запрос.Выполнить();
		
		Если Результат.Пустой() Тогда 
			
			ПроцентНаценки = 0;
			
		Иначе
			
			Выборка = Результат.Выбрать();
			
			Выборка.Следующий();
			
			ПроцентНаценки = Выборка.ПроцентНаценки;
			
		КонецЕсли;	
		
		НоваяСтрока = Объект.Наценки.Добавить();
		
		НоваяСтрока.ВидНаценки			= "Наценка за курс";
		НоваяСтрока.НаценкаРасчетная	= ПроцентНаценки;
		НоваяСтрока.НаценкаДляРТУ		= ПроцентНаценки;
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьРасчетИтогов(Заказ)
	Если Не ЗначениеЗаполнено(Заказ) Тогда
		Возврат;
	КонецЕсли;
	ИтогРасчетнаяСкидка = 0;
	ИтогСкидкаДляРТУ = 0;
	ИтогСкидкаПоРегистру = 0;
	Для Каждого СтрокаТЧ Из Объект.Скидки Цикл
		Если СтрокаТЧ.Заказ <> Заказ Тогда
			Продолжить;
		КонецЕсли;
		// суммирую колонку Скидку расчетную
		ИтогРасчетнаяСкидка = ИтогРасчетнаяСкидка + СтрокаТЧ.СкидкаРасчетная;
		// суммирую колонку Скидку для РТУ
		ИтогСкидкаДляРТУ = ИтогСкидкаДляРТУ + СтрокаТЧ.СкидкаДляРТУ;
		// суммирую колонку Скидку по регистру
		ИтогСкидкаПоРегистру = ИтогСкидкаПоРегистру + СтрокаТЧ.СкидкаПоРегистру;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура РассчитатьСкидкуДляРТУ()  

	ЗначениеСто			= 100;
	СкидкаДляРТУ		= 1;          
	СкидкаНаКурс		= 0;
	СкидкаНаПредоплату	= 0;
	НаценкаНаКурс		= 0;
	
	Для Каждого СтрокаТЗ Из Объект.Скидки Цикл 
		
		Если СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаКурс") Тогда
			
			СкидкаНаКурс = СтрокаТЗ.СкидкаДляРТУ;
			
		ИначеЕсли СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаПредоплату") Тогда
			
			СкидкаНаПредоплату = СтрокаТЗ.СкидкаДляРТУ;
			
		Иначе
			
			Продолжить;
			
		КонецЕсли;	
		
	КонецЦикла;   
	
	Если Объект.ПрименятьНаценки И Объект.Наценки.Количество() Тогда	
		
		НаценкаНаКурс = Объект.Наценки[0].НаценкаДляРТУ; 	
		
	КонецЕсли;	
	
	Если СкидкаНаПредоплату <> 0 Тогда
		
		мСкидкаДляРТУ = ЗначениеСто 
		- (ЗначениеСто - ПроцентСкидкиМаксимум) * (ЗначениеСто - СкидкаНаПредоплату) / ЗначениеСто 
		- НаценкаНаКурс;
		
	ИначеЕсли СкидкаНаКурс <> 0 Тогда
		
		мСкидкаДляРТУ = ЗначениеСто 
		- (ЗначениеСто - ПроцентСкидкиМаксимум) * (ЗначениеСто - СкидкаНаКурс) / ЗначениеСто 
		- НаценкаНаКурс;
		
	Иначе	         
		
		мСкидкаДляРТУ = ПроцентСкидкиМаксимум - НаценкаНаКурс;
		
	КонецЕсли;	
	
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл
		
		СтрокаТЧ.СкидкаДляРТУ = мСкидкаДляРТУ;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура СохранитьСкидкуДляРТУпоЗаказу(Заказ)
	СтруктураПоиска = Новый Структура("Заказ", Заказ);
	СтрокиЗаказа = Объект.СкидкиПоЗаказам.НайтиСтроки(СтруктураПоиска);
	Если СтрокиЗаказа.Количество() > 0 Тогда
		СтрокаЗаказа = СтрокиЗаказа[0];
		СтрокаЗаказа.СкидкаДляРТУ = ИтогСкидкаДляРТУ;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЭтоТоварыВКоробах(Склад)
	Если Не ЗначениеЗаполнено(Склад) Тогда
		Возврат Ложь;
	КонецЕсли;
	ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
		"гф_СкладыТоварыВКоробах");
	
	ТоварыВКоробахЗначение = УправлениеСвойствами.ЗначениеСвойства(Склад, ТоварыВКоробах);	
	
	Если ЗначениеЗаполнено(ТоварыВКоробахЗначение) И ТоварыВКоробахЗначение = Истина Тогда
		 Возврат Истина;
	Иначе
		 Возврат Ложь;
	КонецЕсли;
КонецФункции

&НаСервереБезКонтекста
Функция НайтиКоличествоДнейОтсрочкиПлатежа(Договор)
	Если Не ЗначениеЗаполнено(Договор) Тогда
		Возврат 0;
	КонецЕсли;
	ДопРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
		"гф_ДоговорыКонтрагентовКоличествоДнейОтсрочкиПлатежа");
	КоличествоДнейОтсрочкиПлатежа = УправлениеСвойствами.ЗначениеСвойства(Договор, ДопРеквизит);
	Если ЗначениеЗаполнено(КоличествоДнейОтсрочкиПлатежа) Тогда
		Возврат КоличествоДнейОтсрочкиПлатежа;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции

&НаСервере
Функция ПолучитьСкидкуПоРегистру(ВидСкидки, Период)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_ИсторияИзмененияСкидокСрезПоследних.Скидка КАК Скидка
	               |ИЗ
	               |	РегистрСведений.гф_ИсторияИзмененияСкидок.СрезПоследних(
	               |			&Период,
	               |			ВидСкидки = &ВидСкидки
	               |				И Договор = &Договор
	               |				И Контрагент = &Контрагент
	               |				И Организация = &Организация) КАК гф_ИсторияИзмененияСкидокСрезПоследних";
	Запрос.УстановитьПараметр("Период", Период);
	Запрос.УстановитьПараметр("ВидСкидки", ВидСкидки);
	Запрос.УстановитьПараметр("Контрагент", мКонтрагент);
	Запрос.УстановитьПараметр("Договор", мДоговор);
	Запрос.УстановитьПараметр("Организация", мОрганизация);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Скидка;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции

&НаСервере
Функция ПолучитьРасчетнуюСкидкуПоЗаказуСезонныйЗаказ(ВидСкидки, Дата, КурсЕвро, СкидкаЗаПредоплату)
	
	// Сезонный заказ
	
	// Скидка за предоплату
	Если ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаПредоплату Тогда
		СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(ВидСкидки, Дата);
		Если СкидкаПоРегистру > 0 Тогда
			СкидкаЗаПредоплату = СкидкаПоРегистру;
			Возврат СкидкаПоРегистру;
		Иначе
			Возврат 0;
		КонецЕсли;
	КонецЕсли;
	
	// Скидка за курс
	ЗначениеСемьдесят = 70;
	Если	ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаКурс
		И	СкидкаЗаПредоплату <= 0
		И	КурсЕвро < ЗначениеСемьдесят Тогда
		СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(ВидСкидки, Дата);
		Возврат СкидкаПоРегистру;
	Иначе
		Возврат 0;
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции	

&НаСервере
Функция ПолучитьРасчетнуюСкидкуПоЗаказу(ВидСкидки, Дата, КурсЕвро, СкидкаЗаПредоплату)
	
	Если мКоличествоДнейОтсрочкиПлатежа > 0 Тогда
		Возврат 0;
	КонецЕсли;
		
	Если мСезонныйЗаказ Тогда
		// Сезонный заказ
		
		Возврат ПолучитьРасчетнуюСкидкуПоЗаказуСезонныйЗаказ(ВидСкидки, Дата, КурсЕвро, СкидкаЗаПредоплату);
		
	Иначе
		// НЕ Сезонный заказ
		
		// Скидка за курс
		ЗначениеСемьдесят = 70;
		Если	ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаКурс
			И	КурсЕвро < ЗначениеСемьдесят Тогда
			СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(ВидСкидки, Дата);
			Возврат СкидкаПоРегистру;
		Иначе
			Возврат 0;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьПроцентСкидкиПоЗаказу(Заказ)
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Заказ);
	Запрос.Текст = "ВЫБРАТЬ
	               |	МАКСИМУМ(ЗаказКлиентаТовары.ПроцентРучнойСкидки) КАК Скидка
	               |ИЗ
	               |	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	               |ГДЕ
	               |	ЗаказКлиентаТовары.Ссылка = &Ссылка";
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Скидка;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДанныеИзменены = Ложь;
	ЗаполнитьПроцентСкидки();
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПроцентСкидки()
	ПроцентСкидкиМинимум = 0;
	ПроцентСкидкиМаксимум = 0;
	Для Каждого СтрокаТЗ Из Объект.СкидкиПоЗаказам Цикл
		СкидкаПоЗаказу = ПолучитьПроцентСкидкиПоЗаказу(СтрокаТЗ.Заказ);
		// Процент скидки минимум
		Если Не ЗначениеЗаполнено(ПроцентСкидкиМинимум) Тогда
			ПроцентСкидкиМинимум = СкидкаПоЗаказу;
		Иначе
			ПроцентСкидкиМинимум = ?(ПроцентСкидкиМинимум > СкидкаПоЗаказу, СкидкаПоЗаказу, ПроцентСкидкиМинимум);
		КонецЕсли;
		// Процент скидки максимум
		Если Не ЗначениеЗаполнено(ПроцентСкидкиМаксимум) Тогда
			ПроцентСкидкиМаксимум = СкидкаПоЗаказу;
		Иначе
			ПроцентСкидкиМаксимум = ?(ПроцентСкидкиМаксимум < СкидкаПоЗаказу, СкидкаПоЗаказу, ПроцентСкидкиМаксимум);
		КонецЕсли;
	КонецЦикла;
	Если ПроцентСкидкиМинимум <> ПроцентСкидкиМаксимум Тогда
		ПроцентСкидки = "" + Формат(ПроцентСкидкиМинимум, "ЧДЦ=2; ЧН=0,00") + " - " + Формат(ПроцентСкидкиМаксимум,
			"ЧДЦ=2; ЧН=0,00");
	Иначе
		ПроцентСкидки = "" + Формат(ПроцентСкидкиМинимум, "ЧДЦ=2; ЧН=0,00");
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьКурсЕвро(Дата, ЦифровойКодВалюты)
	Валюта = Справочники.Валюты.НайтиПоКоду(ЦифровойКодВалюты);
	СтруктураКурса = РаботаСКурсамиВалютУТ.ПолучитьКурсВалюты(Валюта, Дата);
	Возврат СтруктураКурса.КурсЧислитель;
КонецФункции

&НаКлиенте
Процедура ДатаДляРТУПриИзменении(Элемент)
	КурсЕвро = ПолучитьКурсЕвро(ДатаДляРТУ, ЦифровойКодВалюты);
	Объект.Скидки.Очистить();
	ЗаполнитьТЧСкидки();
	ЗаполнитьТЧНаценки();
	ЗаполнитьПроцентСкидки();
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура СкидкиПоЗаказамЗаказНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаСервере
Функция ЗаполнитьРезультат()
	
	Результат = Новый Массив;
	
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл
		
		Если СтрокаТЧ.СкидкаДляРТУ = 0 Тогда
			
			СкидкаПоЗаказу = Новый Структура("Заказ, СкидкаДляРТУ");
			ЗаполнитьЗначенияСвойств(СкидкаПоЗаказу, СтрокаТЧ);
			
			КомментарийРТУ = "";
			
			СкидкаПоЗаказу.Вставить("ДатаДляРТУ", ДатаДляРТУ);
			СкидкаПоЗаказу.Вставить("КомментарийРТУ", КомментарийРТУ);
			
			Результат.Добавить(СкидкаПоЗаказу);
			
		ИначеЕсли СтрокаТЧ.СкидкаДляРТУ > 0 Тогда
			
			СкидкаПоЗаказу = Новый Структура("Заказ, СкидкаДляРТУ");
			ЗаполнитьЗначенияСвойств(СкидкаПоЗаказу, СтрокаТЧ);
			
			КомментарийРТУ = "Скидка " + СтрокаТЧ.СкидкаДляРТУ + "%";
			
			СкидкаПоЗаказу.Вставить("ДатаДляРТУ", ДатаДляРТУ);
			СкидкаПоЗаказу.Вставить("КомментарийРТУ", КомментарийРТУ);
			
			Результат.Добавить(СкидкаПоЗаказу);
			
		Иначе
			
			СкидкаПоЗаказу = Новый Структура("Заказ, СкидкаДляРТУ");
			ЗаполнитьЗначенияСвойств(СкидкаПоЗаказу, СтрокаТЧ);
			
			КомментарийРТУ = "Наценка " + (-СтрокаТЧ.СкидкаДляРТУ) + "%";
			
			СкидкаПоЗаказу.Вставить("ДатаДляРТУ", ДатаДляРТУ);
			СкидкаПоЗаказу.Вставить("КомментарийРТУ", КомментарийРТУ);
			
			Результат.Добавить(СкидкаПоЗаказу);

		КонецЕсли;
	
	КонецЦикла;
		
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура СохранитьСкидкуДляРТУ(Команда)
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл
		СтрокаТЧ.СкидкаДляРТУ = мСкидкаДляРТУ;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ДанныеИзменены Тогда
		
		Сообщить("Данные не были записаны!");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СкидкиСкидкаДляРТУПриИзменении(Элемент)
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура НаценкиНаценкаДляРТУПриИзменении(Элемент)
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры


&НаКлиенте
Процедура СкидкиПоЗаказамПриИзменении(Элемент)
	ДанныеИзменены = Истина;
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	
	Результат = ЗаполнитьРезультат();

	ДанныеИзменены = Ложь;
	
	СтруктураВозврата = Новый Структура();
	
	СтруктураВозврата.Вставить("Действие", "ЗаписатьСкидкиПродолжить");
	СтруктураВозврата.Вставить("Результат", Результат);
	Закрыть(СтруктураВозврата);
	
КонецПроцедуры

#КонецОбласти
